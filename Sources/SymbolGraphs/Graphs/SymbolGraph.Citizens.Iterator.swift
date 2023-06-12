import Symbols

extension SymbolGraph.Citizens
{
    @frozen public
    struct Iterator
    {
        @usableFromInline internal
        let base:SymbolGraph.Citizens
        @usableFromInline internal
        var index:Int32

        @inlinable internal
        init(_ base:SymbolGraph.Citizens)
        {
            self.base = base
            self.index = self.base.nodes.startIndex
        }
    }
}
extension SymbolGraph.Citizens.Iterator:IteratorProtocol
{
    @inlinable public mutating
    func next() -> (index:Int32, symbol:ScalarSymbol)?
    {
        while self.index < self.base.nodes.endIndex
        {
            defer
            {
                self.index = self.base.nodes.index(after: self.index)
            }
            if  self.base.contains(self.index)
            {
                return (self.index, self.base.symbols[self.index])
            }
        }
        return nil
    }
}
