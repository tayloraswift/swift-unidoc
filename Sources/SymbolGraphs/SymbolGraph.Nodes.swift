extension SymbolGraph
{
    @frozen public
    struct Nodes:Equatable, Sendable
    {
        public
        var symbols:SymbolTable<ScalarAddress>

        @usableFromInline internal
        var values:[Node]

        @inlinable internal
        init(symbols:SymbolTable<ScalarAddress> = .init(), values:[Node] = [])
        {
            self.symbols = symbols
            self.values = values
        }
    }
}
extension SymbolGraph.Nodes
{
    @inlinable public mutating
    func push(_ scalar:SymbolGraph.Scalar?, id:ScalarSymbol) throws -> ScalarAddress
    {
        self.values.append(.init(scalar: scalar))
        return try self.symbols(id)
    }
}
extension SymbolGraph.Nodes:RandomAccessCollection
{
    @inlinable public
    var startIndex:ScalarAddress
    {
        .init(value: .init(self.values.startIndex))
    }
    @inlinable public
    var endIndex:ScalarAddress
    {
        .init(value: .init(self.values.endIndex))
    }
    @inlinable public
    subscript(address:ScalarAddress) -> SymbolGraph.Node
    {
        _read
        {
            yield  self.values[.init(address.value)]
        }
        _modify
        {
            yield &self.values[.init(address.value)]
        }
    }
}
