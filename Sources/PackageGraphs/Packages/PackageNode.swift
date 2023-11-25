import SymbolGraphs
import Symbols

/// A package node is a flattened representation of a package manifest.
/// Creating one involves assigning an identity to a package manifest
/// and flattening all intra-package target dependency chains.
@frozen public
struct PackageNode:Identifiable
{
    public
    let id:Symbol.Package
    public
    var dependencies:[any Identifiable<Symbol.Package>]

    public
    var products:[SymbolGraphMetadata.Product]
    public
    var modules:[SymbolGraph.Module]
    /// Lists of excluded sources, one per target node.
    public
    var exclude:[[String]]
    public
    var root:Symbol.FileBase

    @inlinable public
    init(id:Symbol.Package,
        dependencies:[any Identifiable<Symbol.Package>],
        products:[SymbolGraphMetadata.Product],
        modules:[SymbolGraph.Module],
        exclude:[[String]],
        root:Symbol.FileBase)
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
    var predecessors:Predecessors { .init(self.dependencies) }
}
extension PackageNode
{
    public consuming
    func flattened(dependencies:[PackageNode]) throws -> Self
    {
        try self.flatten(dependencies: dependencies)
        return self
    }

    mutating
    func flatten(dependencies:[PackageNode]) throws
    {
        var nodes:DigraphExplorer<ProductNode>.Nodes = .init()
        for package:PackageNode in dependencies
        {
            for product:SymbolGraphMetadata.Product in package.products
            {
                try nodes.index(.init(id: .init(name: product.name, package: package.id),
                    predecessors: product.dependencies))
            }
        }

        var cache:[Symbol.Product: [Symbol.Product]] = [:]

        self.products = try self.products.map
        {
            .init(name: $0.name, type: $0.type,
                dependencies: try nodes.included(by: $0.dependencies, cache: &cache),
                cultures: $0.cultures)
        }
        self.modules = try self.modules.map
        {
            .init(name: $0.name, type: $0.type, dependencies: .init(
                    products: try nodes.included(by: $0.dependencies.products,
                        cache: &cache),
                    modules: $0.dependencies.modules),
                location: $0.location)
        }

        let declared:[Symbol.Package: any Identifiable<Symbol.Package>] =
            self.dependencies.reduce(into: [:]) { $0[$1.id] = $1 }

        let actuallyUsed:Set<Symbol.Package> = cache.values.reduce(into: [])
        {
            for product:Symbol.Product in $1
            {
                $0.insert(product.package)
            }
        }

        self.dependencies = try Self.order(topologically: dependencies).compactMap
        {
            actuallyUsed.contains($0.id)
                ? declared[$0.id] ?? TransitiveDependency.init(id: $0.id)
                : nil
        }
    }
}
