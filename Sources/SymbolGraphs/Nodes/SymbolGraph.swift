import Symbols

@frozen public
struct SymbolGraph:Equatable, Sendable
{
    public
    var symbols:SymbolTable<ScalarAddress, ScalarSymbol>

    @usableFromInline internal
    var nodes:[Node]

    @inlinable internal
    init(symbols:SymbolTable<ScalarAddress, ScalarSymbol> = .init(),
        nodes:[Node] = [])
    {
        self.symbols = symbols
        self.nodes = nodes
    }
}
extension SymbolGraph
{
    /// Appends a new node to the symbol graph, and its associated symbol to the
    /// symbol. This function doesn’t check for duplicates.
    @inlinable public mutating
    func append(_ scalar:SymbolGraph.Scalar?, id:ScalarSymbol) throws -> ScalarAddress
    {
        self.nodes.append(.init(scalar: scalar))
        return try self.symbols.append(id)
    }
}
extension SymbolGraph
{
    @inlinable public
    var citizens:Citizens { .init(self) }

    @inlinable public
    var allocated:Range<ScalarAddress>
    {
        .init(value: .init(self.nodes.startIndex))
        ..<
        .init(value: .init(self.nodes.endIndex))
    }

    @_semantics("array.get_count")
    @inlinable public
    var count:Int
    {
        self.nodes.count
    }

    @inlinable public
    subscript(address:ScalarAddress) -> SymbolGraph.Node?
    {
        self.nodes.indices.contains(address.offset) ? self[allocated: address] : nil
    }
    /// Accesses the node at the specified address. This subscript traps if
    /// the address has not been allocated.
    @_semantics("array.subscript")
    @inlinable public
    subscript(allocated address:ScalarAddress) -> SymbolGraph.Node
    {
        _read
        {
            yield  self.nodes[address.offset]
        }
        _modify
        {
            yield &self.nodes[address.offset]
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
        self.count
    }
}
extension SymbolGraph
{
    @inlinable public
    func link<T>(
        static transform:(Int) throws -> T,
        dynamic:(ScalarSymbol) throws -> T) rethrows -> SymbolTable<ScalarAddress, T>
    {
        var elements:[T] = [] ; elements.reserveCapacity(self.symbols.count)

        for index:Int in self.symbols.indices
        {
            elements.append(self.citizens.contains(index) ? try transform(index) :
                try dynamic(self.symbols[index]))
        }

        return .init(elements: elements)
    }
}
