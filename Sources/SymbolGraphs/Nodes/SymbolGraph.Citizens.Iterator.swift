import Symbols

extension SymbolGraph.Citizens
{
    @frozen public
    struct Iterator
    {
        @usableFromInline internal
        let base:SymbolGraph.Citizens
        @usableFromInline internal
        var index:Int

        @inlinable internal
        init(_ base:SymbolGraph.Citizens)
        {
            self.base = base
            self.index = self.base.graph.nodes.startIndex
        }
    }
}
extension SymbolGraph.Citizens.Iterator:IteratorProtocol
{
    @inlinable public mutating
    func next() -> (offset:Int, symbol:ScalarSymbol)?
    {
        while self.index < self.base.graph.nodes.endIndex
        {
            defer
            {
                self.index = self.base.graph.nodes.index(after: self.index)
            }
            if  self.base.contains(self.index)
            {
                return (self.index, self.base.graph.symbols[self.index])
            }
        }
        return nil
    }
}
