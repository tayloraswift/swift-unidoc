import PackageGraphs
import SymbolGraphs
import Symbols

extension PackageNode
{
    public static
    func libraries(as id:consuming Symbol.Package,
        flattening manifest:borrowing PackageManifest,
        platform:borrowing SymbolGraphMetadata.Platform) throws -> Self
    {
        try .init(as: id, flattening: manifest, platform: platform)
        {
            switch $0
            {
            case .library:  true
            case _:         false
            }
        }
    }
    public
    init(as id:Symbol.Package,
        flattening manifest:borrowing PackageManifest,
        platform:borrowing SymbolGraphMetadata.Platform,
        filter predicate:(SymbolGraphMetadata.ProductType) throws -> Bool) throws
    {
        try self.init(id: id,
            predecessors: manifest.dependencies,
            platform: platform,
            products: try manifest.products.filter { try predicate($0.type) },
            targets: try .init(indexing: manifest.targets),
            root: manifest.root)
    }
    private
    init(id:Symbol.Package,
        predecessors:[PackageManifest.Dependency],
        platform:borrowing SymbolGraphMetadata.Platform,
        products:borrowing [PackageManifest.Product],
        targets:borrowing DigraphExplorer<TargetNode>.Nodes,
        root:Symbol.FileBase) throws
    {
        let ordering:[TargetNode] = try targets.included(by: products,
            on: platform)

        self.init(id: id,
            dependencies: predecessors,
            products: try products.map
            {
                let constituents:Set<String> = try targets.included(by: $0, on: platform)

                var (modules, dependencies):([Int], Set<Symbol.Product>) = ([], [])
                for (index, constituent):(Int, TargetNode) in ordering.enumerated()
                    where constituents.contains(constituent.name)
                {
                    dependencies.formUnion(constituent.dependencies.products(on: platform))
                    modules.append(index)
                }
                return .init(name: $0.name, type: $0.type,
                    dependencies: dependencies.sorted(),
                    cultures: modules)
            },
            modules: try ordering.map
            {
                let constituents:Set<String> = try targets.included(by: $0, on: platform)

                var (modules, dependencies):([Int], Set<Symbol.Product>) = ([], [])
                for (index, constituent):(Int, TargetNode) in ordering.enumerated()
                    where constituents.contains(constituent.name)
                {
                    dependencies.formUnion(constituent.dependencies.products(on: platform))
                    //  don’t include the target’s own index
                    if  constituent.name != $0.name
                    {
                        modules.append(index)
                    }
                }

                return .init(name: $0.name, type: $0.type, dependencies: .init(
                        products: dependencies.sorted(),
                        modules: modules),
                    location: $0.path)
            },
            exclude: ordering.map(\.exclude),
            root: root)
    }
}
