import BSON

extension Realm.Sitemap
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
extension Realm.Sitemap.Elements:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Volume.Shoot...)
    {
        self.init(bytes: [])

        for element:Volume.Shoot in arrayLiteral
        {
            self.append(element)
        }
    }
}
extension Realm.Sitemap.Elements
{
    @inlinable internal mutating
    func append(_ shoot:Volume.Shoot)
    {
        shoot.serialize(into: &self.bytes) ; self.bytes.append(0x0A)
    }
}
extension Realm.Sitemap.Elements:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(bytes: self.bytes)
    }
}
extension Realm.Sitemap.Elements:BSONEncodable
{
    public
    func encode(to field:inout BSON.FieldEncoder)
    {
        BSON.BinaryView<[UInt8]>.init(subtype: .generic, slice: self.bytes).encode(to: &field)
    }
}
extension Realm.Sitemap.Elements:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(bytes: [UInt8].init(bson.slice))
    }
}
