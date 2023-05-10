import Symbols

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
extension SymbolGraph.Nodes
{
    @_semantics("array.check_subscript")
    @inlinable public
    func contains(address:ScalarAddress) -> Bool
    {
        self.values.indices ~= .init(address.value)
    }
    @inlinable public
    subscript(address:ScalarAddress) -> SymbolGraph.Node?
    {
        self.contains(address: address) ? self[allocated: address] : nil
    }
    /// Accesses the node at the specified address. This subscript traps if
    /// the address has not been allocated.
    @_semantics("array.subscript")
    @inlinable public
    subscript(allocated address:ScalarAddress) -> SymbolGraph.Node
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
extension SymbolGraph.Nodes:Sequence
{
    @inlinable public
    func withContiguousStorageIfAvailable<Success>(
        _ body:(UnsafeBufferPointer<SymbolGraph.Node>) throws -> Success) rethrows -> Success?
    {
        try self.values.withContiguousStorageIfAvailable(body)
    }
    @inlinable public
    func makeIterator() -> IndexingIterator<[SymbolGraph.Node]>
    {
        self.values.makeIterator()
    }
    @inlinable public
    var underestimatedCount:Int
    {
        self.values.count
    }
}
