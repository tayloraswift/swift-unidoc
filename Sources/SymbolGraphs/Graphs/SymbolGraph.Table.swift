import BSONDecoding
import BSONEncoding

extension SymbolGraph
{
    /// A wrapper around an array that statically guarantees that its
    /// indices are representable in 24 bits, and can be indexed with ``Int32``.
    @frozen public
    struct Table<Element>
    {
        @usableFromInline internal
        var elements:[Element]

        @inlinable internal
        init(elements:[Element] = [])
        {
            self.elements = elements
        }
    }
}
extension SymbolGraph.Table:Equatable where Element:Equatable
{
}
extension SymbolGraph.Table:Hashable where Element:Hashable
{
}
extension SymbolGraph.Table:Sendable where Element:Sendable
{
}
extension SymbolGraph.Table
{
    @inlinable public mutating
    func reserveCapacity(_ capacity:Int)
    {
        self.elements.reserveCapacity(capacity)
    }
    /// Appends an element to the table. Traps if the index of the new
    /// table element cannot be represented in 24 bits.
    @inlinable public mutating
    func append(_ element:__owned Element) -> Int32
    {
        let next:Int = self.elements.count
        if  0 ... 0x00_ff_ff_ff ~= next
        {
            self.elements.append(element)
            return .init(next)
        }
        else
        {
            fatalError("SymbolGraph.Table index overflow (\(next) elements)")
        }
    }

    @inlinable public
    func map<T>(_ transform:(_ address:Int32, _ element:Element) throws -> T)
        rethrows -> SymbolGraph.Table<T>
    {
        .init(elements: try self.indices.map { try transform($0, self[$0]) })
    }
}
extension SymbolGraph.Table:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Element...)
    {
        if  arrayLiteral.count <= 0x00_ff_ff_ff
        {
            self.init(elements: arrayLiteral)
        }
        else
        {
            fatalError("SymbolGraph.Table index overflow (\(arrayLiteral.count) elements)")
        }
    }
}
extension SymbolGraph.Table:Sequence
{
    @inlinable public
    func withContiguousStorageIfAvailable<Success>(
        _ body:(UnsafeBufferPointer<Element>) throws -> Success) rethrows -> Success?
    {
        try self.elements.withContiguousStorageIfAvailable(body)
    }
    @inlinable public
    var underestimatedCount:Int
    {
        self.elements.count
    }
}
extension SymbolGraph.Table:RandomAccessCollection
{
    @_semantics("array.get_count")
    @inlinable public
    var count:Int
    {
        self.elements.count
    }

    @inlinable public
    var startIndex:Int32
    {
        .init(self.elements.startIndex)
    }
    @inlinable public
    var endIndex:Int32
    {
        .init(self.elements.endIndex)
    }
    @_semantics("array.subscript")
    @inlinable public
    subscript(index:Int32) -> Element
    {
        _read
        {
            yield  self[Int.init(index)]
        }
        _modify
        {
            yield &self[Int.init(index)]
        }
    }
}
extension SymbolGraph.Table
{
    @inlinable public
    subscript(index:Int) -> Element
    {
        _read
        {
            yield  self.elements[index]
        }
        _modify
        {
            yield &self.elements[index]
        }
    }
}
extension SymbolGraph.Table:BSONEncodable, BSONWeakEncodable where Element:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.elements.encode(to: &field)
    }
}
extension SymbolGraph.Table:BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(elements: try .init(bson: bson))
    }
}
