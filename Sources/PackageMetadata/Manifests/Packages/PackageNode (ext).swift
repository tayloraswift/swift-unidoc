import ModuleGraphs
import PackageGraphs

extension PackageNode
{
    public static
    func libraries(as id:__owned PackageIdentifier,
        flattening manifest:__shared PackageManifest,
        platform:__shared PlatformIdentifier) throws -> Self
    {
        try .init(as: id, flattening: manifest, platform: platform)
        {
            switch $0
            {
            case .library:  return true
            case _:         return false
            }
        }
    }
    public
    init(as id:__owned PackageIdentifier,
        flattening manifest:__shared PackageManifest,
        platform:__shared PlatformIdentifier,
        filter predicate:(ProductType) throws -> Bool) throws
    {
        try self.init(id: id,
            predecessors: manifest.dependencies,
            platform: platform,
            products: try manifest.products.filter { try predicate($0.type) },
            targets: try .init(indexing: manifest.targets),
            root: manifest.root)
    }
    private
    init(id:__owned PackageIdentifier,
        predecessors:__owned [Dependency],
        platform:__shared PlatformIdentifier,
        products:__shared [PackageManifest.Product],
        targets:__shared DigraphExplorer<TargetNode>.Nodes,
        root:Repository.Root) throws
    {
        let ordering:[TargetNode] = try targets.included(by: products,
            on: platform)

        self.init(id: id,
            dependencies: predecessors,
            products: try products.map
            {
                let constituents:Set<String> = try targets.included(by: $0, on: platform)

                var (modules, dependencies):([Int], Set<ProductIdentifier>) = ([], [])
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

                var (modules, dependencies):([Int], Set<ProductIdentifier>) = ([], [])
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
