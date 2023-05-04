extension SymbolGraph
{
    @frozen public
    struct Nodes
    {
        public
        var symbols:SymbolTable<ScalarAddress>

        @usableFromInline internal
        var elements:[Node]

        @inlinable internal
        init(symbols:SymbolTable<ScalarAddress> = .init(), elements:[Node] = [])
        {
            self.symbols = symbols
            self.elements = elements
        }
    }
}
extension SymbolGraph.Nodes
{
    @inlinable public mutating
    func push(_ scalar:SymbolGraph.Scalar?, id:ScalarSymbol) throws -> ScalarAddress
    {
        self.elements.append(.init(scalar: scalar))
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
            yield  self.elements[.init(address.value)]
        }
        _modify
        {
            yield &self.elements[.init(address.value)]
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
