import PackageGraphs
import PackageMetadata
import SymbolGraphs
import Symbols

extension SSGC {
    struct PackageGraph: ~Copyable {
        //  Nominal dependencies mean we need to build the package-to-product mapping before
        //  we can actually create the (partitioned) dependency nodes.
        private var packageContainingProduct: [String: Symbol.Package]
        private var packageManifests: [Symbol.Package: SPM.Manifest]
        private var packagesUnused: Set<Symbol.Package>
        private(set) var sparseEdges: [(ModuleGraph.NodeIdentifier, ModuleGraph.NodeIdentifier)]

        let platform: SymbolGraphMetadata.Platform

        init(platform: SymbolGraphMetadata.Platform) {
            self.packageContainingProduct = [:]
            self.packageManifests = [:]
            self.packagesUnused = []
            self.sparseEdges = []

            self.platform = platform
        }
    }
}
extension SSGC.PackageGraph {
    private func diagnoseUnusedPackages() {
        if !self.packagesUnused.isEmpty {
            print(
                """
                Note: \
                the following packages were never used in any documentation-bearing product:
                """
            )
        }
        for (i, package): (Int, Symbol.Package) in self.packagesUnused.sorted().enumerated() {
            print("\(i + 1). \(package)")
        }
    }
}
extension SSGC.PackageGraph {
    private mutating func indexProducts(in manifest: SPM.Manifest, from id: Symbol.Package) {
        for product: SPM.Manifest.Product in manifest.products.values {
            self.packageContainingProduct[product.name] = id
        }
    }
    mutating func attach(_ dependencyManifest: SPM.Manifest, as id: Symbol.Package) {
        self.packageManifests[id] = dependencyManifest
        self.indexProducts(in: dependencyManifest, from: id)
    }
}
extension SSGC.PackageGraph {
    /// Densifies the internal module (but not product) dependencies for the given dependency.
    private mutating func normalizeManifest(
        for id: Symbol.Package,
        with traits: Set<SymbolGraphMetadata.Trait>,
    ) throws -> PackageNode {
        let dependencyManifest: SPM.Manifest = try {
            if  var dependencyManifest: SPM.Manifest = $0 {
                try dependencyManifest.normalizeUnqualifiedDependencies(
                    with: self.packageContainingProduct
                )
                $0 = dependencyManifest
                return dependencyManifest
            } else {
                fatalError("No manifest found for '\(id)'")
            }
        } (&self.packageManifests[id])

        return try .init(from: dependencyManifest, as: id, on: self.platform, traits: traits)
    }

    private mutating func createEdges(
        from normalizedManifest: SPM.Manifest,
        with traits: Set<SymbolGraphMetadata.Trait>,
        as id: Symbol.Package
    ) {
        for target: TargetNode in normalizedManifest.targets.values {
            let dependent: SSGC.ModuleGraph.NodeIdentifier = .init(
                package: id,
                module: .init(mangling: target.id)
            )
            for dependency: String in target.dependencies.targets(
                    on: self.platform,
                    traits: traits
                ) {
                let dependency: SSGC.ModuleGraph.NodeIdentifier = .init(
                    package: id,
                    module: .init(mangling: dependency)
                )
                self.sparseEdges.append((dependency, dependent))
            }
            for dependency: Symbol.Product in target.dependencies.products(
                    on: self.platform,
                    traits: traits
                ) {
                guard
                let dependencyManifest: SPM.Manifest = self.packageManifests[
                    dependency.package
                ],
                let product: SPM.Manifest.Product = dependencyManifest.products[
                    dependency.name
                ] else {
                    //  This is OK, some of the targets were never actually built, so they
                    //  might reference packages we don’t know about.
                    self.packagesUnused.insert(dependency.package)
                    continue
                }

                for constituent: String in product.targets {
                    let dependency: SSGC.ModuleGraph.NodeIdentifier = .init(
                        package: dependency.package,
                        module: .init(mangling: constituent)
                    )

                    self.sparseEdges.append((dependency, dependent))
                }
            }
        }
    }

    mutating func join(
        dependencies dependencyPins: [SPM.DependencyPin],
        sinkManifest: SPM.Manifest,
        sinkPackage: Symbol.Package
    ) throws -> ([PackageNode], PackageNode) {
        /// when we build documentation, we enable all the traits in the sink package
        /// this is not the same as enabling every trait in the build graph!
        let sinkEnabled: Set<SymbolGraphMetadata.Trait> = sinkManifest.traits.keys.reduce(
            into: ["default"]
        ) {
            $0.insert($1)
        }

        let traits: [Symbol.Package: Set<SymbolGraphMetadata.Trait>] = TraitExplorer.collect(
            context: self.packageManifests
        ) {
            $0.walk(package: sinkManifest, traits: sinkEnabled)
        }

        if !traits.isEmpty {
            print(
                """
                Note: \
                the following dependencies have package traits enabled:
                """
            )
            for (dependency, traitsEnabled):
                (Symbol.Package, Set<SymbolGraphMetadata.Trait>) in traits.sorted(
                    by: { $0.key < $1.key }
                ) {
                print(
                    """
                        \(dependency): \(traitsEnabled.sorted())
                    """
                )
            }
        }

        /// This pass must not make any assumptions about the ordering of the pins.
        ///
        /// These nodes are partially flattened, but they are still considered partitioned, as
        /// we have not yet flattened the product dependencies.
        let dependencies: [PackageNode] = try dependencyPins.reduce(into: []) {
            let traits: Set<SymbolGraphMetadata.Trait> = traits[$1.identity] ?? []
            $0.append(try self.normalizeManifest(for: $1.identity, with: traits))
        }

        for (id, dependencyManifest): (Symbol.Package, SPM.Manifest) in self.packageManifests {
            self.createEdges(from: dependencyManifest, with: traits[id] ?? [], as: id)
        }

        self.indexProducts(in: sinkManifest, from: sinkPackage)
        var sinkManifest: SPM.Manifest = sinkManifest
        try sinkManifest.normalizeUnqualifiedDependencies(with: self.packageContainingProduct)

        let sink: PackageNode = try .init(
            from: sinkManifest,
            as: sinkPackage,
            on: self.platform,
            traits: sinkEnabled
        )

        self.createEdges(from: sinkManifest, with: sinkEnabled, as: sinkPackage)
        self.diagnoseUnusedPackages()

        return (dependencies, sink)
    }
}
