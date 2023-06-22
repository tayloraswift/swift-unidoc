import ModuleGraphs

/// A package node is a flattened representation of a package manifest.
/// Creating one involves assigning an identity to a package manifest
/// and flattening all intra-package target dependency chains.
@frozen public
struct PackageNode:Identifiable
{
    public
    let id:PackageIdentifier
    public
    let dependencies:[Dependency]

    public
    let products:[ProductDetails]
    public
    let modules:[ModuleDetails]
    /// Lists of excluded sources, one per target node.
    public
    let exclude:[[String]]
    public
    let root:Repository.Root

    @inlinable public
    init(id:PackageIdentifier,
        dependencies:[Dependency],
        products:[ProductDetails],
        modules:[ModuleDetails],
        exclude:[[String]],
        root:Repository.Root)
    {
        self.id = id
        self.dependencies = dependencies
        self.products = products
        self.modules = modules
        self.exclude = exclude
        self.root = root
    }
}
extension PackageNode:DigraphNode
{
    @inlinable public
    var predecessors:[Dependency] { self.dependencies }
}
extension PackageNode
{
    public __consuming
    func flattened(dependencies:[PackageNode]) throws -> Self
    {
        var nodes:DigraphExplorer<ProductNode>.Nodes = .init()
        for package:PackageNode in dependencies
        {
            for product:ProductDetails in package.products
            {
                try nodes.index(.init(id: .init(name: product.name, package: package.id),
                    predecessors: product.dependencies))
            }
        }

        var cache:[ProductIdentifier: [ProductIdentifier]] = [:]

        let products:[ProductDetails] = try self.products.map
        {
            .init(name: $0.name, type: $0.type,
                dependencies: try nodes.included(by: $0.dependencies, cache: &cache),
                cultures: $0.cultures)
        }
        let modules:[ModuleDetails] = try self.modules.map
        {
            .init(name: $0.name, type: $0.type, dependencies: .init(
                    products: try nodes.included(by: $0.dependencies.products,
                        cache: &cache),
                    modules: $0.dependencies.modules),
                location: $0.location)
        }

        let dependencies:[Dependency] = try self.order(dependencies: dependencies)
        //  Lint unused dependencies
        let used:Set<PackageIdentifier> = .init(cache.values.joined().lazy.map(\.package))

        return .init(id: self.id,
            dependencies: dependencies.filter { used.contains($0.id) },
            products: products,
            modules: modules,
            exclude: self.exclude,
            root: self.root)
    }
    private
    func order(dependencies:[PackageNode]) throws -> [Dependency]
    {
        var direct:[PackageIdentifier: Dependency] = [:]
        for dependency:Dependency in self.dependencies
        {
            direct[dependency.id] = dependency
        }
        return try PackageNode.order(topologically: dependencies).map
        {
            direct[$0.id] ?? .transitive($0.id)
        }
    }
}
