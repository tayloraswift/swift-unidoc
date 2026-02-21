extension SymbolGraph.Layer.Citizens {
    @frozen public struct Iterator {
        @usableFromInline internal let base: SymbolGraph.Layer<Node>
        @usableFromInline internal var index: Int32

        @inlinable internal init(_ base: SymbolGraph.Layer<Node>) {
            self.base = base
            self.index = self.base.nodes.startIndex
        }
    }
}
extension SymbolGraph.Layer.Citizens.Iterator: IteratorProtocol {
    @inlinable public mutating func next() -> (index: Int32, symbol: Node.ID)? {
        while self.index < self.base.nodes.endIndex {
            defer {
                self.index = self.base.nodes.index(after: self.index)
            }
            if  self.base.contains(citizen: self.index) {
                return (self.index, self.base.symbols[self.index])
            }
        }
        return nil
    }
}
