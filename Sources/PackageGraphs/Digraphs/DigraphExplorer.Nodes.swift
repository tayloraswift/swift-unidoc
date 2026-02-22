import SymbolGraphs
import Symbols

extension DigraphExplorer {
    /// An index of identifiable digraph nodes.
    @frozen public struct Nodes {
        @usableFromInline internal var index: [Node.ID: Node]

        @inlinable internal init(index: [Node.ID: Node] = [:]) {
            self.index = index
        }
    }
}
extension DigraphExplorer.Nodes {
    @inlinable internal mutating func index(_ node: Node) throws {
        if  case _? = self.index.updateValue(node, forKey: node.id) {
            throw DigraphNodeError<Node>.duplicate(node.id)
        }
    }
}
extension DigraphExplorer.Nodes {
    @inlinable internal func callAsFunction(_ id: Node.ID) throws -> Node {
        if  let node: Node = self.index[id] {
            return node
        } else {
            throw DigraphNodeError<Node>.undefined(id)
        }
    }
}
extension DigraphExplorer<TargetNode>.Nodes {
    @inlinable public init(indexing nodes: some Sequence<TargetNode>) throws {
        self.init()
        for node: TargetNode in nodes {
            try self.index(node)
        }
    }
    /// Returns *all* targets in the index that are included, directly or indirectly,
    /// by the given target. This function is aware of platform conditionals.
    public func included(
        by target: TargetNode,
        on platform: SymbolGraphMetadata.Platform
    ) throws -> Set<String> {
        var explorer: DigraphExplorer<TargetNode> = .init(nodes: self)
        explorer.explore(node: target)
        let included: [String: TargetNode] = try explorer.conquer {
            for dependency: String in $1.dependencies.targets(on: platform) {
                try $0.explore(node: dependency)
            }
        }
        return .init(included.keys)
    }
}
extension DigraphExplorer<ProductNode>.Nodes {
    /// Returns *all* nodes in the index that are included, directly or indirectly,
    /// by any of the given products. Each element in the returned array is unique.
    func included(
        by products: [Symbol.Product],
        cache: inout [Symbol.Product: [Symbol.Product]]
    ) throws -> [Symbol.Product] {
        var included: Set<Symbol.Product> = []
        for id: Symbol.Product in products {
            try {
                let products: [Symbol.Product] = try $0 ?? self.included(by: id)
                included.formUnion(products)
                $0 = products
            } (&cache[id])
        }
        return included.sorted()
    }
    private func included(by product: Symbol.Product) throws -> [Symbol.Product] {
        var explorer: DigraphExplorer<Node> = .init(nodes: self)
        try explorer.explore(node: product)
        let included: [Node.ID: Node] = try explorer.conquer {
            for predecessor: Node.ID in $1.predecessors {
                try $0.explore(node: predecessor)
            }
        }
        return .init(included.keys)
    }
}
