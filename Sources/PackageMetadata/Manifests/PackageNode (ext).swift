import PackageGraphs
import SymbolGraphs
import Symbols

extension PackageNode
{
    public
    init(from manifest:borrowing SPM.Manifest,
        on platform:borrowing SymbolGraphMetadata.Platform,
        as id:Symbol.Package,
        filter:borrowing (SymbolGraph.ProductType) throws -> Bool = { _ in true }) throws
    {
        let products:[SPM.Manifest.Product] = try manifest.products.values.filter
        {
            try filter($0.type)
        }
        let modules:DigraphExplorer<TargetNode>.Nodes = try .init(
            indexing: manifest.targets.values)
        let modulesInOrder:[TargetNode] = try modules.included(by: products,
            on: platform)

        self.init(id: id,
            dependencies: manifest.dependencies,
            snippets: manifest.snippets ?? "Snippets",
            products: try products.map
            {
                let constituents:Set<String> = try modules.included(by: $0, on: platform)

                var (modules, dependencies):([Int], Set<Symbol.Product>) = ([], [])
                for (index, constituent):(Int, TargetNode) in modulesInOrder.enumerated()
                    where constituents.contains(constituent.name)
                {
                    dependencies.formUnion(constituent.dependencies.products(on: platform))
                    modules.append(index)
                }
                return .init(name: $0.name, type: $0.type,
                    dependencies: dependencies.sorted(),
                    cultures: modules)
            },
            modules: try modulesInOrder.map
            {
                let constituents:Set<String> = try modules.included(by: $0, on: platform)

                var (modules, dependencies):([Int], Set<Symbol.Product>) = ([], [])
                for (index, constituent):(Int, TargetNode) in modulesInOrder.enumerated()
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
            exclude: modulesInOrder.map(\.exclude),
            root: manifest.root)
    }
}
