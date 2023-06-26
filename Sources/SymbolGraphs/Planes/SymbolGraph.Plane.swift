import BSONDecoding
import BSONEncoding

extension SymbolGraph
{
    @frozen public
    struct Plane<Type, Element> where Type:ScalarPlaneType
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
extension SymbolGraph.Plane:Sendable where Element:Sendable
{
}
extension SymbolGraph.Plane
{
    @inlinable public mutating
    func append(_ element:Element) -> Int32
    {
        Type.plane | self.table.append(element)
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
extension SymbolGraph.Plane:RandomAccessCollection
{
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
extension SymbolGraph.Plane:BSONEncodable, BSONWeakEncodable where Element:BSONEncodable
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
