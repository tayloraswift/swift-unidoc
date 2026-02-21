extension SymbolGraph.Layer {
    /// A sequence view of the citizen symbols of this symbolgraph. Citizen symbols
    /// are symbols associated with a scalar that is declared by a module in this
    /// symbolgraph.
    @frozen public struct Citizens {
        @usableFromInline internal let layer: SymbolGraph.Layer<Node>

        @inlinable internal init(_ layer: SymbolGraph.Layer<Node>) {
            self.layer = layer
        }
    }
}
extension SymbolGraph.Layer.Citizens: Sequence {
    @inlinable public func makeIterator() -> Iterator {
        .init(self.layer)
    }
}
