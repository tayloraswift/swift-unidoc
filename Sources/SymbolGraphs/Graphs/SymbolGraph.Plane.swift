import BSONDecoding
import BSONEncoding
import Unidoc

extension SymbolGraph
{
    @frozen public
    struct Plane<Type, Element> where Type:UnidocPlaneType
    {
        @usableFromInline internal
        var table:Table<Element>

        @inlinable internal
        init(table:Table<Element> = [])
        {
            self.table = table
        }
    }
}
extension SymbolGraph.Plane:Equatable where Element:Equatable
{
}
extension SymbolGraph.Plane:Hashable where Element:Hashable
{
}
extension SymbolGraph.Plane:Sendable where Element:Sendable
{
}
extension SymbolGraph.Plane
{
    @inlinable public mutating
    func reserveCapacity(_ capacity:Int)
    {
        self.table.reserveCapacity(capacity)
    }
    @inlinable public mutating
    func append(_ element:Element) -> Int32
    {
        Type.plane | self.table.append(element)
    }

    @inlinable public
    func map<T>(_ transform:(_ address:Int32, _ element:Element) throws -> T)
        rethrows -> SymbolGraph.Plane<Type, T>
    {
        .init(table: .init(elements: try self.indices.map { try transform($0, self[$0]) }))
    }
}
extension SymbolGraph.Plane:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Element...)
    {
        self.init(table: .init(elements: arrayLiteral))
    }
}
extension SymbolGraph.Plane:Sequence
{
    @inlinable public
    func withContiguousStorageIfAvailable<Success>(
        _ body:(UnsafeBufferPointer<Element>) throws -> Success) rethrows -> Success?
    {
        try self.table.withContiguousStorageIfAvailable(body)
    }
    @inlinable public
    var underestimatedCount:Int
    {
        self.table.count
    }
}
extension SymbolGraph.Plane:RandomAccessCollection
{
    @_semantics("array.get_count")
    @inlinable public
    var count:Int
    {
        self.table.count
    }

    @inlinable public
    var startIndex:Int32
    {
        Type.plane | self.table.startIndex
    }
    @inlinable public
    var endIndex:Int32
    {
        Type.plane | self.table.endIndex
    }

    @_semantics("array.subscript")
    @inlinable public
    subscript(scalar:Int32) -> Element
    {
        _read
        {
            yield  self.table[scalar & .significand]
        }
        _modify
        {
            yield &self.table[scalar & .significand]
        }
    }
}
extension SymbolGraph.Plane:BSONEncodable where Element:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.table.encode(to: &field)
    }
}
extension SymbolGraph.Plane:BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(table: try .init(bson: bson))
    }
}
