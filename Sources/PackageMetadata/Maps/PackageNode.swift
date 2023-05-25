import ModuleGraphs

@available(*, deprecated, renamed: "PackageNode")
public
typealias PackageMap = PackageNode

/// A package node is a flattened representation of a package manifest.
/// Creating one involves assigning an identity to a package manifest
/// and flattening all intra-package target dependency chains.
@frozen public
struct PackageNode:Identifiable
{
    public
    let id:PackageIdentifier
    public
    let predecessors:[PackageManifest.Dependency]
    /// Nodes representing the products included from the relevant package.
    /// Each node contains all targets included in the associated product,
    /// either through direct inclusion, or inclusion through target
    /// dependencies. It also includes upstream products depended upon by
    /// any of those targets. (But it does not include any products that
    /// those products themselves may depend on.)
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
    init(id:PackageIdentifier,
        predecessors:[PackageManifest.Dependency],
        products:[ProductNode],
        targets:[TargetNode],
        exclude:[[String]],
        root:Repository.Root)
    {
        self.id = id
        self.predecessors = predecessors
        self.products = products
        self.targets = targets
        self.exclude = exclude
        self.root = root
    }
}
extension PackageNode:DigraphNode
{
}
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
        predecessors:__owned [PackageManifest.Dependency],
        platform:__shared PlatformIdentifier,
        products:__shared [PackageManifest.Product],
        targets:__shared Targets,
        root:Repository.Root) throws
    {
        let ordering:[PackageManifest.Target] = try targets.included(by: products,
            on: platform)

        self.init(id: id,
            predecessors: predecessors,
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
