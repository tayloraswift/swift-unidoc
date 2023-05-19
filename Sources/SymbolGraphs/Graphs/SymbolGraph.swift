import Symbols

@frozen public
struct SymbolGraph:Equatable, Sendable
{
    public
    var symbols:SymbolTable<ScalarAddress>

    @usableFromInline internal
    var nodes:[Node]

    @inlinable internal
    init(symbols:SymbolTable<ScalarAddress> = .init(),
        nodes:[Node] = [])
    {
        self.symbols = symbols
        self.nodes = nodes
    }
}
extension SymbolGraph
{
    @inlinable public mutating
    func push(_ scalar:SymbolGraph.Scalar?, id:ScalarSymbol) throws -> ScalarAddress
    {
        self.nodes.append(.init(scalar: scalar))
        return try self.symbols(id)
    }
}
extension SymbolGraph
{
    @_semantics("array.check_subscript")
    @inlinable public
    func contains(address:ScalarAddress) -> Bool
    {
        self.nodes.indices ~= .init(address.value)
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
            yield  self.nodes[.init(address.value)]
        }
        _modify
        {
            yield &self.nodes[.init(address.value)]
        }
    }
}
extension SymbolGraph:Sequence
{
    @inlinable public
    func withContiguousStorageIfAvailable<Success>(
        _ body:(UnsafeBufferPointer<SymbolGraph.Node>) throws -> Success) rethrows -> Success?
    {
        try self.nodes.withContiguousStorageIfAvailable(body)
    }
    @inlinable public
    func makeIterator() -> IndexingIterator<[SymbolGraph.Node]>
    {
        self.nodes.makeIterator()
    }
    @inlinable public
    var underestimatedCount:Int
    {
        self.nodes.count
    }
}
