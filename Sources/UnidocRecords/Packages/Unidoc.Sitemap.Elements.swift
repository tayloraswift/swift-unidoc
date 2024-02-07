import BSON
import UnidocAPI

extension Unidoc.Sitemap
{
    @frozen public
    struct Elements:Equatable, Sendable
    {
        @usableFromInline internal
        var bytes:[UInt8]

        @inlinable internal
        init(bytes:[UInt8])
        {
            self.bytes = bytes
        }
    }
}
extension Unidoc.Sitemap.Elements:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Unidoc.Shoot...)
    {
        self.init(bytes: [])

        for element:Unidoc.Shoot in arrayLiteral
        {
            self.append(element)
        }
    }
}
extension Unidoc.Sitemap.Elements
{
    @inlinable internal mutating
    func append(_ shoot:Unidoc.Shoot)
    {
        shoot.serialize(into: &self.bytes) ; self.bytes.append(0x0A)
    }
}
extension Unidoc.Sitemap.Elements:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(bytes: self.bytes)
    }
}
extension Unidoc.Sitemap.Elements:BSONEncodable
{
    public
    func encode(to field:inout BSON.FieldEncoder)
    {
        BSON.BinaryView<[UInt8]>.init(subtype: .generic, bytes: self.bytes).encode(to: &field)
    }
}
extension Unidoc.Sitemap.Elements:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<ArraySlice<UInt8>>) throws
    {
        self.init(bytes: [UInt8].init(bson.bytes))
    }
}
