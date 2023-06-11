extension SymbolGraph
{
    @frozen public
    struct Nodes:Equatable, Sendable
    {
        @usableFromInline internal
        var elements:[Node]

        @inlinable internal
        init(elements:[Node])
        {
            self.elements = elements
        }
    }
}
extension SymbolGraph.Nodes
{
    @inlinable internal mutating
    func append(scalar:SymbolGraph.Scalar?)
    {
        self.elements.append(.init(scalar: scalar))
    }
    @inlinable internal
    func contains(_ address:ScalarAddress) -> Bool
    {
        self.elements.indices.contains(address.offset)
    }
}
extension SymbolGraph.Nodes:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:SymbolGraph.Node...)
    {
        self.init(elements: arrayLiteral)
    }
}
extension SymbolGraph.Nodes:Sequence
{
    @inlinable public
    func withContiguousStorageIfAvailable<Success>(
        _ body:(UnsafeBufferPointer<SymbolGraph.Node>) throws -> Success) rethrows -> Success?
    {
        try self.elements.withContiguousStorageIfAvailable(body)
    }
    @inlinable public
    var underestimatedCount:Int
    {
        self.elements.count
    }
}
extension SymbolGraph.Nodes:RandomAccessCollection
{
    @_semantics("array.get_count")
    @inlinable public
    var count:Int
    {
        self.elements.count
    }

    @inlinable public
    var startIndex:ScalarAddress
    {
        .init(value: .init(self.elements.startIndex))
    }
    @inlinable public
    var endIndex:ScalarAddress
    {
        .init(value: .init(self.elements.endIndex))
    }
    /// Accesses the node at the specified address. This subscript traps if
    /// the address has not been allocated.
    @_semantics("array.subscript")
    @inlinable public
    subscript(index:ScalarAddress) -> SymbolGraph.Node
    {
        _read
        {
            yield  self.elements[index.offset]
        }
        _modify
        {
            yield &self.elements[index.offset]
        }
    }
}
