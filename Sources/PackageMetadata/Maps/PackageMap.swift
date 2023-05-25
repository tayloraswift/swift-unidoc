import PackageGraphs

@frozen public
struct PackageMap
{
    public
    let products:[ProductNode]
    public
    let targets:[TargetNode]
    /// Lists of excluded sources, one per target node.
    public
    let exclude:[[String]]
    public
    let root:Repository.Root

    private
    init(products:[ProductNode],
        targets:[TargetNode],
        exclude:[[String]],
        root:Repository.Root)
    {
        self.products = products
        self.targets = targets
        self.exclude = exclude
        self.root = root
    }
}
extension PackageMap
{
    public static
    func libraries(
        from manifest:__shared PackageManifest,
        platform:__shared PlatformIdentifier) throws -> Self
    {
        try .init(from: manifest, platform: platform)
        {
            switch $0
            {
            case .library:  return true
            case _:         return false
            }
        }
    }
    public
    init(from manifest:__shared PackageManifest,
        platform:__shared PlatformIdentifier,
        where predicate:(ProductType) throws -> Bool) throws
    {
        try self.init(platform: platform,
            products: try manifest.products.filter { try predicate($0.type) },
            targets: try .init(indexing: manifest.targets),
            root: manifest.root)
    }
    private
    init(platform:__shared PlatformIdentifier,
        products:__shared [PackageManifest.Product],
        targets:__shared Targets,
        root:Repository.Root) throws
    {
        let ordering:[PackageManifest.Target] = try targets.included(by: products,
            on: platform)

        self.init(
            products: try products.map
            {
                let constituents:Set<String> = try targets.included(by: $0, on: platform)

                var (modules, dependencies):([Int], Set<ProductIdentifier>) = ([], [])
                for (index, constituent):(Int, PackageManifest.Target) in ordering.enumerated()
                    where constituents.contains(constituent.name)
                {
                    dependencies.formUnion(constituent.dependencies.products(on: platform))
                    modules.append(index)
                }
                return .init(name: $0.name, type: $0.type, dependencies: .init(
                    products: dependencies.sorted(),
                    modules: modules))
            },
            targets: try ordering.map
            {
                let constituents:Set<String> = try targets.included(by: $0, on: platform)

                var (modules, dependencies):([Int], Set<ProductIdentifier>) = ([], [])
                for (index, constituent):(Int, PackageManifest.Target) in ordering.enumerated()
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
