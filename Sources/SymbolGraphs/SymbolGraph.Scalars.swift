extension SymbolGraph
{
    @frozen public
    struct Scalars
    {
        public
        var symbols:SymbolTable<ScalarAddress>

        @usableFromInline internal
        var nodes:[ScalarNode]

        init(symbols:SymbolTable<ScalarAddress> = .init(), nodes:[ScalarNode] = [])
        {
            self.symbols = symbols
            self.nodes = nodes
        }
    }
}
extension SymbolGraph.Scalars
{
    @inlinable public mutating
    func push(_ scalar:SymbolGraph.Scalar?, id:ScalarIdentifier) throws -> ScalarAddress
    {
        self.nodes.append(.init(scalar))
        return try self.symbols(id)
    }
}
extension SymbolGraph.Scalars
{
    @inlinable public
    subscript(address:ScalarAddress) -> SymbolGraph.ScalarNode
    {
        _read
        {
            yield  self.nodes[.init(address.value)]
        }
        _modify
        {
            yield &self.nodes[.init(address.value)]
        }
    }
}
