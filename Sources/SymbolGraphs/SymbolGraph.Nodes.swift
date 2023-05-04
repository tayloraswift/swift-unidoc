extension SymbolGraph
{
    @frozen public
    struct Nodes
    {
        public
        var symbols:SymbolTable<ScalarAddress>

        @usableFromInline internal
        var nodes:[Node]

        init(symbols:SymbolTable<ScalarAddress> = .init(), nodes:[Node] = [])
        {
            self.symbols = symbols
            self.nodes = nodes
        }
    }
}
extension SymbolGraph.Nodes
{
    @inlinable public mutating
    func push(_ scalar:SymbolGraph.Scalar?, id:ScalarSymbol) throws -> ScalarAddress
    {
        self.nodes.append(.init(scalar: scalar))
        return try self.symbols(id)
    }
}
extension SymbolGraph.Nodes
{
    @inlinable public
    subscript(address:ScalarAddress) -> SymbolGraph.Node
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
    @inlinable public
    subscript(address:ScalarAddress) -> SymbolGraph.Scalar?
    {
        _read
        {
            yield  self[address].scalar
        }
        _modify
        {
            yield &self[address].scalar
        }
    }
    @inlinable public
    subscript(address:ScalarAddress, extension:Int) -> SymbolGraph.Extension
    {
        _read
        {
            yield  self[address].extensions[`extension`]
        }
        _modify
        {
            yield &self[address].extensions[`extension`]
        }
    }
}
