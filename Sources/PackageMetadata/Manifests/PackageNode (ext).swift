import PackageGraphs
import SymbolGraphs
import Symbols

extension PackageNode
{
    public static
    func all(flattening manifest:borrowing SPM.Manifest,
        on platform:borrowing SymbolGraphMetadata.Platform,
        as id:consuming Symbol.Package) throws -> Self
    {
        try .init(as: id, flattening: manifest, platform: platform) { _ in true }
    }
}
extension PackageNode
{
    private
    init(as id:Symbol.Package,
        flattening manifest:borrowing SPM.Manifest,
        platform:borrowing SymbolGraphMetadata.Platform,
        filter predicate:(SymbolGraph.ProductType) throws -> Bool) throws
    {
        try self.init(id: id,
            predecessors: manifest.dependencies,
            platform: platform,
            products: try manifest.products.values.filter { try predicate($0.type) },
            targets: try .init(indexing: manifest.targets.values),
            root: manifest.root)
    }
    private
    init(id:Symbol.Package,
        predecessors:[SPM.Manifest.Dependency],
        platform:borrowing SymbolGraphMetadata.Platform,
        products:borrowing [SPM.Manifest.Product],
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
