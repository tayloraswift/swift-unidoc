import SymbolGraphs
import Symbols
import TopologicalSorting

/// A package node is a flattened representation of a package manifest.
/// Creating one involves assigning an identity to a package manifest
/// and flattening all intra-package target dependency chains.
@frozen public struct PackageNode: Identifiable {
    public let id: Symbol.Package
    public var dependencies: [any Identifiable<Symbol.Package>]

    /// The name of the snippets directory.
    public var snippets: String
    public var products: [SymbolGraph.Product]
    public var modules: [SymbolGraph.Module]
    /// Lists of excluded sources, one per target node.
    public var exclude: [[String]]
    public var root: Symbol.FileBase

    @inlinable public init(
        id: Symbol.Package,
        dependencies: [any Identifiable<Symbol.Package>],
        snippets: String,
        products: [SymbolGraph.Product],
        modules: [SymbolGraph.Module],
        exclude: [[String]],
        root: Symbol.FileBase
    ) {
        self.id = id
        self.dependencies = dependencies
        self.snippets = snippets
        self.products = products
        self.modules = modules
        self.exclude = exclude
        self.root = root
    }
}
extension PackageNode {
    public consuming func joined(with dependencies: [PackageNode]) throws -> (
        [Densified],
        Densified
    ) {
        let nodes: DigraphExplorer<ProductNode>.Nodes = try dependencies.reduce(into: .init()) {
            for product: SymbolGraph.Product in $1.products {
                let id: Symbol.Product = .init(name: product.name, package: $1.id)
                try $0.index(.init(id: id, predecessors: product.dependencies))
            }
        }

        let densifiedUpstream: [Densified] = try dependencies.map {
            try $0.densified(products: nodes, packages: dependencies)
        }
        let densifiedSink: Densified = try self.densified(
            products: nodes,
            packages: dependencies
        )

        return (densifiedUpstream, densifiedSink)
    }

    private consuming func densified(
        products: DigraphExplorer<ProductNode>.Nodes,
        packages: [PackageNode]
    ) throws -> Densified {
        var cache: [Symbol.Product: [Symbol.Product]] = [:]

        for i: Int in self.products.indices {
            try {
                $0 = try products.included(by: $0, cache: &cache)
            } (&self.products[i].dependencies)
        }
        for i: Int in self.modules.indices {
            try {
                $0 = try products.included(by: $0, cache: &cache)
            } (&self.modules[i].dependencies.products)
        }

        let dependenciesActuallyUsed: Set<Symbol.Package> = cache.values.reduce(into: []) {
            for product: Symbol.Product in $1 {
                $0.insert(product.package)
            }
        }

        let dependenciesDeclared: [Symbol.Package: any Identifiable<Symbol.Package>] =
        self.dependencies.reduce(into: [:]) { $0[$1.id] = $1 }

        let dependenciesBlamed: [any Identifiable<Symbol.Package>] = packages.reduce(
            into: []
        ) {
            if  dependenciesActuallyUsed.contains($1.id) {
                $0.append(dependenciesDeclared[$1.id] ?? TransitiveDependency.init(id: $1.id))
            }
        }

        return .init(
            dependencies: dependenciesBlamed,
            products: self.products,
            modules: self.modules
        )
    }
}
