import PackageGraphs
import PackageMetadata
import SemanticVersions
import SymbolGraphs
import Symbols
import SystemIO

extension SSGC
{
    @_spi(testable) public
    struct ModuleGraph
    {
        private
        let upstreamPackages:[any Identifiable<Symbol.Package>]
        /// Individualized dependencies of each module in the graph, including all transitive
        /// dependencies, and the module itself, but not including constant ``substrate``
        /// dependencies.
        private
        let constituents:[NodeIdentifier: [Node]]
        /// Modules that are assumed to be dependencies of every module in the module graph.
        private
        let substrate:[ModuleLayout]

        let products:[SymbolGraph.Product]
        let cultures:[Node]

        @_spi(testable) public
        let snippets:[LazyFile]

        private
        init(upstreamPackages:[any Identifiable<Symbol.Package>],
            constituents:[NodeIdentifier: [Node]],
            substrate:[ModuleLayout],
            products:[SymbolGraph.Product],
            cultures:[Node],
            snippets:[LazyFile])
        {
            self.upstreamPackages = upstreamPackages
            self.constituents = constituents
            self.substrate = substrate
            self.products = products
            self.cultures = cultures
            self.snippets = snippets
        }
    }
}
extension SSGC.ModuleGraph
{
    static func book(name id:Symbol.Package, root:FilePath.Directory) throws -> Self
    {
        let root:SSGC.PackageRoot = .init(normalizing: root)
        let layouts:[SSGC.ModuleLayout] = try root.chapters()
        let modules:[Node] = layouts.map { .init(module: $0, in: id) }

        return .init(
            upstreamPackages: [],
            constituents: modules.reduce(into: [:]) { $0[$1.id] = [$1] },
            substrate: [],
            products: [],
            cultures: modules,
            snippets: [])
    }

    static func stdlib(platform:SymbolGraphMetadata.Platform, version:MinorVersion) -> Self
    {
        let stdlib:(products:[SymbolGraph.Product], modules:[SymbolGraph.Module])

        switch (platform, version)
        {
        case (.linux, .v(6, 0)):    stdlib = Self.linux_6_0
        case (.linux, _):           stdlib = Self.linux_5_10
        case (.macOS, .v(6, 0)):    stdlib = Self.macOS_6_0
        case (.macOS, _):           stdlib = Self.macOS_5_10
        default:                    fatalError("Unsupported platform: \(platform)")
        }

        var constituents:[NodeIdentifier: [Node]] = [:]
        let modules:[Node] = stdlib.modules.map
        {
            .init(module: .init(toolchain: $0), in: .swift)
        }
        for module:Node in modules
        {
            constituents[module.id] = module.layout.dependencies.modules.map { modules[$0] }
        }

        return .init(
            upstreamPackages: [],
            constituents: constituents,
            substrate: [],
            products: stdlib.products,
            cultures: modules,
            snippets: [])
    }

    static func package(sink:PackageNode,
        dependencies:[PackageNode],
        substrate:[SSGC.ModuleLayout],
        sparseEdges:[(NodeIdentifier, NodeIdentifier)]) throws -> Self
    {
        let directedEdges:[(Symbol.Package, Symbol.Package)] = dependencies.reduce(into: [])
        {
            for dependency:any Identifiable<Symbol.Package> in $1.dependencies
            {
                $0.append((dependency.id, $1.id))
            }
        }

        //  FIXME: in Swift 6, it will be legal to have cyclic package dependencies!
        guard
        let dependencies:[PackageNode] = dependencies.sortedTopologically(by: directedEdges)
        else
        {
            throw DigraphCycleError<PackageNode>.init()
        }

        let dependencyTopologies:[PackageNode.Densified]
        let sinkTopology:PackageNode.Densified

        (dependencyTopologies, sinkTopology) = try sink.joined(with: dependencies)

        var constituentsFromHomePackage:[Symbol.Product: [Node]] = [:]
        var constituents:[NodeIdentifier: [Node]] = [:]
        var nodes:[Node] = []

        for (dependencyTopology, dependency):(PackageNode.Densified, PackageNode) in zip(
            dependencyTopologies,
            dependencies)
        {
            let root:SSGC.PackageRoot = .init(normalizing: dependency.root)
            let layouts:[SSGC.ModuleLayout] = try root.layouts(
                modules: dependencyTopology.modules,
                exclude: dependency.exclude)

            let modules:[Node] = layouts.map
            {
                let node:Node = .init(module: $0, in: dependency.id)
                nodes.append(node)
                return node
            }
            for module:Node in modules
            {
                constituents[module.id] = module.layout.dependencies.modules.map { modules[$0] }
            }
            for product:SymbolGraph.Product in dependency.products
            {
                let id:Symbol.Product = .init(name: product.name, package: dependency.id)
                constituentsFromHomePackage[id] = product.cultures.map { modules[$0] }
            }
        }

        let root:SSGC.PackageRoot = .init(normalizing: sink.root)
        let layouts:[SSGC.ModuleLayout] = try root.layouts(
            modules: sinkTopology.modules,
            exclude: sink.exclude)
        let modules:[Node] = layouts.map
        {
            let node:Node = .init(module: $0, in: sink.id)
            nodes.append(node)
            return node
        }
        for module:Node in modules
        {
            constituents[module.id] = module.layout.dependencies.modules.map { modules[$0] }
        }
        for product:SymbolGraph.Product in sink.products
        {
            let id:Symbol.Product = .init(name: product.name, package: sink.id)
            constituentsFromHomePackage[id] = product.cultures.map { modules[$0] }
        }

        //  This needs to happen in a second pass, to account for future cyclic dependencies.
        for node:Node in nodes
        {
            try
            {
                for product:Symbol.Product in node.layout.dependencies.products
                {
                    if  let modules:[Node] = constituentsFromHomePackage[product]
                    {
                        $0 += modules
                    }
                    else
                    {
                        throw TargetNode.DependencyError.undefinedProduct(product)
                    }
                }

                if  let sorted:[Node] = $0.sortedTopologically(by: sparseEdges)
                {
                    $0 = sorted
                }
                else
                {
                    throw DigraphCycleError<Node>.init()
                }

                //  Every module is a constituent of itself.
                $0.append(node)

            } (&constituents[node.id, default: []])
        }

        guard
        let snippetsDirectory:FilePath.Component = .init(sink.snippets)
        else
        {
            throw SSGC.SnippetDirectoryError.invalid(sink.snippets)
        }

        return .init(
            upstreamPackages: sinkTopology.dependencies,
            constituents: constituents,
            substrate: substrate,
            products: sinkTopology.products,
            cultures: modules,
            snippets: try root.snippets(in: snippetsDirectory))
    }
}
extension SSGC.ModuleGraph
{
    /// Filters the given dependency pins, returning the dependencies that are actually used by
    /// at least one package product.
    func dependenciesUsed(
        among dependencyPins:[SPM.DependencyPin]) throws -> [SymbolGraphMetadata.Dependency]
    {
        let dependenciesIndexed:SPM.DependencyPins = try .init(indexing: dependencyPins)
        let dependenciesPinned:[SymbolGraphMetadata.Dependency] = try self.upstreamPackages.map
        {
            let pin:SPM.DependencyPin = try dependenciesIndexed($0.id)
            return .init(package: .init(scope: pin.location.owner, name: $0.id),
                requirement: ($0 as? SPM.Manifest.Dependency)?.requirement?.stable,
                revision: pin.revision,
                version: pin.version)
        }
        let dependenciesUsed:Set<Symbol.Package> = self.products.reduce(into: [])
        {
            guard
            case .library = $1.type
            else
            {
                return
            }
            for dependency:Symbol.Product in $1.dependencies
            {
                $0.insert(dependency.package)
            }
        }

        return dependenciesPinned.filter { dependenciesUsed.contains($0.package.name) }
    }
}
extension SSGC.ModuleGraph
{
    private
    func plan(for module:NodeIdentifier) -> [SSGC.ModuleLayout]
    {
        self.substrate + self.constituents[module, default: []].map(\.layout)
    }

    /// Returns all dependencies of the given module (including transitive dependencies),
    /// sorted in topological dependency order. The list begins with all the ``substrate``
    /// modules and ends with the given module.
    var plans:[(SSGC.ModuleLayout, [SSGC.ModuleLayout])]
    {
        self.cultures.map { ($0.layout, self.plan(for: $0.id)) }
    }
}
extension SSGC.ModuleGraph
{
    func symbolDumpCommands(scratch:SSGC.PackageBuildDirectory? = nil,
        minimumAccessLevel:Symbol.ACL = .internal,
        emitExtensionBlockSymbols:Bool = true,
        includeInterfaceSymbols:Bool = true,
        skipInheritedDocs:Bool = true) throws -> [SSGC.Toolchain.SymbolDumpOptions]
    {
        /// Compute the union of the non-substrate constituents of all modules being built.
        let nodes:[NodeIdentifier: Node] = self.cultures.reduce(into: [:])
        {
            for constituent:Node in self.constituents[$1.id, default: []]
            {
                $0[constituent.id] = constituent
            }
        }

        var modules:[SSGC.Toolchain.SymbolDumpOptions] = nodes.map
        {
            let plan:[SSGC.ModuleLayout] = self.plan(for: $0)
            return plan.reduce(into: .init(
                moduleName: $1.layout.module.id,
                includePaths: scratch.map { [$0.modules] } ?? [],
                minimumAccessLevel: minimumAccessLevel,
                emitExtensionBlockSymbols: emitExtensionBlockSymbols,
                includeInterfaceSymbols: includeInterfaceSymbols,
                skipInheritedDocs: skipInheritedDocs))
            {
                let constituent:Symbol.Module = $1.module.id
                if  constituent != $0.moduleName
                {
                    $0.allowedReexportedModules.append(constituent)
                }

                switch $1.module.language
                {
                case .cpp?: break
                case .c?:   break
                default:    return
                }

                $0.includePaths += $1.include

                if  let file:FilePath = $1.modulemap ??
                        scratch?.modulemap(target: $1.module.name)
                {
                    $0.moduleMaps.append(file)
                }
            }
        }

        modules.sort { $0.moduleName < $1.moduleName }
        return modules
    }
}
//  https://forums.swift.org/t/dependency-graph-of-the-standard-library-modules/59267
extension SSGC.ModuleGraph
{
    static var macOS_5_10:([SymbolGraph.Product], [SymbolGraph.Module])
    {
        (
            [
                .init(name: "__stdlib__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 4)),
                .init(name: "__corelibs__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 7)),
            ],
            [
                //  0:
                .toolchain(module: "Swift"),
                //  1:
                .toolchain(module: "_Concurrency",
                    dependencies: 0),
                //  2:
                .toolchain(module: "Distributed",
                    dependencies: 0, 1),

                //  3:
                .toolchain(module: "_StringProcessing",
                    dependencies: 0),
                //  4:
                .toolchain(module: "RegexBuilder",
                    dependencies: 0, 3),

                //  5:
                .toolchain(module: "Dispatch",
                    dependencies: 0),
                //  6:
                .toolchain(module: "DispatchIntrospection",
                    dependencies: 0),
                //  7:
                .toolchain(module: "Foundation",
                    dependencies: 0, 5),
            ]
        )
    }

    static var linux_5_10:([SymbolGraph.Product], [SymbolGraph.Module])
    {
        (
            [
                .init(name: "__stdlib__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 7)),
                .init(name: "__corelibs__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 13)),
            ],
            [
                //  0:
                .toolchain(module: "Swift"),
                //  1:
                .toolchain(module: "_Concurrency",
                    dependencies: 0),
                //  2:
                .toolchain(module: "Distributed",
                    dependencies: 0, 1),

                //  3:
                .toolchain(module: "_Differentiation",
                    dependencies: 0),

                //  4:
                .toolchain(module: "_RegexParser",
                    dependencies: 0),
                //  5:
                .toolchain(module: "_StringProcessing",
                    dependencies: 0, 4),
                //  6:
                .toolchain(module: "RegexBuilder",
                    dependencies: 0, 4, 5),

                //  7:
                .toolchain(module: "Cxx",
                    dependencies: 0),

                //  8:
                .toolchain(module: "Dispatch",
                    dependencies: 0),
                //  9:
                .toolchain(module: "DispatchIntrospection",
                    dependencies: 0),
                // 10:
                .toolchain(module: "Foundation",
                    dependencies: 0, 8),
                // 11:
                .toolchain(module: "FoundationNetworking",
                    dependencies: 0, 8, 10),
                // 12:
                .toolchain(module: "FoundationXML",
                    dependencies: 0, 8, 10),
                // 13:
                .toolchain(module: "XCTest",
                    dependencies: 0),
            ]
        )
    }
}
extension SSGC.ModuleGraph
{
    static var macOS_6_0:([SymbolGraph.Product], [SymbolGraph.Module])
    {
        (
            [
                .init(name: "__stdlib__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 6)),
                .init(name: "__corelibs__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 9)),
            ],
            [
                //  0:
                .toolchain(module: "Swift"),
                //  1:
                .toolchain(module: "_Concurrency",
                    dependencies: 0),
                //  2:
                .toolchain(module: "Distributed",
                    dependencies: 0, 1),

                //  3:
                .toolchain(module: "_StringProcessing",
                    dependencies: 0),
                //  4:
                .toolchain(module: "RegexBuilder",
                    dependencies: 0, 3),
                //  5:
                .toolchain(module: "Synchronization",
                    dependencies: 0),
                //  6:
                .toolchain(module: "Cxx",
                    dependencies: 0),

                //  7:
                .toolchain(module: "Dispatch",
                    dependencies: 0),
                //  8:
                .toolchain(module: "DispatchIntrospection",
                    dependencies: 0, 7),
                //  9:
                .toolchain(module: "Foundation",
                    dependencies: 0, 7, 8),
            ]
        )
    }

    static var linux_6_0:([SymbolGraph.Product], [SymbolGraph.Module])
    {
        (
            [
                .init(name: "__stdlib__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 8)),
                .init(name: "__corelibs__", type: .library(.automatic),
                    dependencies: [],
                    cultures: [Int].init(0 ... 16)),
            ],
            [
                //  0:
                .toolchain(module: "Swift"),
                //  1:
                .toolchain(module: "_Concurrency",
                    dependencies: 0),
                //  2:
                .toolchain(module: "Distributed",
                    dependencies: 0, 1),

                //  3:
                .toolchain(module: "_Differentiation",
                    dependencies: 0),

                //  4:
                .toolchain(module: "_RegexParser",
                    dependencies: 0),
                //  5:
                .toolchain(module: "_StringProcessing",
                    dependencies: 0, 4),
                //  6:
                .toolchain(module: "RegexBuilder",
                    dependencies: 0, 4, 5),
                //  7:
                .toolchain(module: "Synchronization",
                    dependencies: 0),
                //  8:
                .toolchain(module: "Cxx",
                    dependencies: 0),

                //  9:
                .toolchain(module: "Dispatch",
                    dependencies: 0),
                // 10:
                .toolchain(module: "DispatchIntrospection",
                    dependencies: 0, 9),
                // 11:
                .toolchain(module: "FoundationEssentials",
                    dependencies: 0, 4, 5, 9),
                // 12:
                .toolchain(module: "FoundationInternationalization",
                    dependencies: 0, 4, 5, 9, 11),
                // 13:
                .toolchain(module: "Foundation",
                    dependencies: 0, 4, 5, 9, 11, 12),
                // 14:
                .toolchain(module: "FoundationNetworking",
                    dependencies: 0, 4, 5, 9, 11, 12, 13),
                // 15:
                .toolchain(module: "FoundationXML",
                    dependencies: 0, 4, 5, 9, 11, 12, 13),

                // 16:
                .toolchain(module: "XCTest",
                    dependencies: 0, 4, 5, 9, 11, 12, 13),
            ]
        )
    }
}
