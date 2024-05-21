import BSON
import UnidocAPI

extension Unidoc.Sitemap
{
    @frozen public
    struct Elements:Equatable, Sendable
    {
        @usableFromInline internal
        var bytes:ArraySlice<UInt8>

        @inlinable internal
        init(bytes:ArraySlice<UInt8>)
        {
            self.bytes = bytes
        }
    }
}
extension Unidoc.Sitemap.Elements
{
    @inlinable static
    var separator:UInt8 { 0x0A }
}
extension Unidoc.Sitemap.Elements:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(bytes: self.bytes)
    }
}
extension Unidoc.Sitemap.Elements:BSONBinaryEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson += self.bytes
    }
}
extension Unidoc.Sitemap.Elements:BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder)
    {
        self.init(bytes: bson.bytes)
    }
}
