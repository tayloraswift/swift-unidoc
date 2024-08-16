import PackageGraphs
import PackageMetadata
import SymbolGraphs
import Symbols

extension SSGC
{
    struct PackageGraph:~Copyable
    {
        //  Nominal dependencies mean we need to build the package-to-product mapping before
        //  we can actually create the (partitioned) dependency nodes.
        private
        var packageContainingProduct:[String: Symbol.Package]
        private
        var packageManifests:[Symbol.Package: SPM.Manifest]
        private
        var packagesUnused:Set<Symbol.Package>
        private
        var sparseEdges:[(Vertex, Vertex)]

        let platform:SymbolGraphMetadata.Platform

        init(platform:SymbolGraphMetadata.Platform)
        {
            self.packageContainingProduct = [:]
            self.packageManifests = [:]
            self.packagesUnused = []
            self.sparseEdges = []

            self.platform = platform
        }
    }
}
extension SSGC.PackageGraph
{
    private mutating
    func indexProducts(in manifest:SPM.Manifest, from id:Symbol.Package)
    {
        for product:SPM.Manifest.Product in manifest.products.values
        {
            self.packageContainingProduct[product.name] = id
        }
    }
    mutating
    func attach(_ dependencyManifest:SPM.Manifest, as id:Symbol.Package)
    {
        self.packageManifests[id] = dependencyManifest
        self.indexProducts(in: dependencyManifest, from: id)
    }
}
extension SSGC.PackageGraph
{
    /// Densifies the internal module (but not product) dependencies for the given dependency.
    private mutating
    func normalizeManifest(for id:Symbol.Package) throws -> PackageNode
    {
        let dependencyManifest:SPM.Manifest = try
        {
            if  var dependencyManifest:SPM.Manifest = $0
            {
                try dependencyManifest.normalizeUnqualifiedDependencies(
                    with: self.packageContainingProduct)
                $0 = dependencyManifest
                return dependencyManifest
            }
            else
            {
                fatalError("No manifest found for '\(id)'")
            }
        } (&self.packageManifests[id])

        return try .all(flattening: dependencyManifest, on: self.platform, as: id)
    }

    private mutating
    func createEdges(from normalizedManifest:SPM.Manifest, as id:Symbol.Package)
    {
        for target:TargetNode in normalizedManifest.targets.values
        {
            let dependent:Vertex = .init(package: id, module: .init(mangling: target.id))
            for dependency:String in target.dependencies.targets(on: self.platform)
            {
                let dependency:Vertex = .init(package: id, module: .init(mangling: dependency))
                self.sparseEdges.append((dependency, dependent))
            }
            for dependency:Symbol.Product in target.dependencies.products(on: self.platform)
            {
                guard
                let dependencyManifest:SPM.Manifest = self.packageManifests[dependency.package],
                let product:SPM.Manifest.Product = dependencyManifest.products[dependency.name]
                else
                {
                    //  This is OK, some of the targets were never actually built, so they
                    //  might reference packages we don’t know about.
                    self.packagesUnused.insert(dependency.package)
                    continue
                }

                for constituent:String in product.targets
                {
                    let dependency:Vertex = .init(
                        package: dependency.package,
                        module: .init(mangling: constituent))

                    self.sparseEdges.append((dependency, dependent))
                }
            }
        }
    }

    consuming
    func join(dependencies pins:[SPM.DependencyPin],
        with sinkManifest:inout SPM.Manifest,
        as id:Symbol.Package) throws -> SSGC.ModuleGraph
    {
        /// This pass must not make any assumptions about the ordering of the pins.
        ///
        /// These nodes are partially flattened, but they are still considered partitioned, as
        /// we have not yet flattened the product dependencies.
        let dependencies:[PackageNode] = try pins.reduce(into: [])
        {
            $0.append(try self.normalizeManifest(for: $1.identity))
        }

        for (id, dependencyManifest):(Symbol.Package, SPM.Manifest) in self.packageManifests
        {
            self.createEdges(from: dependencyManifest, as: id)
        }

        self.indexProducts(in: sinkManifest, from: id)
        try sinkManifest.normalizeUnqualifiedDependencies(with: self.packageContainingProduct)

        self.createEdges(from: sinkManifest, as: id)

        if !self.packagesUnused.isEmpty
        {
            print("""
                Note: \
                the following packages were never used in any documentation-bearing product:
                """)
        }
        for (i, package):(Int, Symbol.Package) in self.packagesUnused.sorted().enumerated()
        {
            print("\(i + 1). \(package)")
        }

        let standardLibrary:SSGC.StandardLibrary = .init(platform: self.platform)

        return try .init(
            standardLibrary: standardLibrary.modules.map(SSGC.ModuleLayout.init(toolchain:)),
            sparseEdges: self.sparseEdges,
            dependencies: dependencies,
            sink: try .all(flattening: sinkManifest, on: self.platform, as: id))
    }
}
