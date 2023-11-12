import BSONDecoding
import BSONEncoding
import MD5
import URI

extension Volume
{
    @frozen public
    struct SiteMap<ID>:Identifiable where ID:Hashable
    {
        public
        let id:ID
        public
        let lines:[UInt8]

        @inlinable public
        init(id:ID, lines:[UInt8])
        {
            self.id = id
            self.lines = lines
        }
    }
}
extension Volume.SiteMap:Equatable where ID:Equatable
{
}
extension Volume.SiteMap:Sendable where ID:Sendable
{
}
extension Volume.SiteMap
{
    @frozen public
    enum CodingKey:String
    {
        case id = "_id"
        case lines = "L"
        case hash = "H"
    }
}
extension Volume.SiteMap:BSONDocumentEncodable, BSONEncodable
    where ID:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.lines] = BSON.BinaryView<[UInt8]>.init(subtype: .generic, slice: self.lines)
        bson[.hash] = MD5.init(hashing: self.lines)
    }
}
extension Volume.SiteMap:BSONDocumentDecodable, BSONDocumentViewDecodable, BSONDecodable
    where ID:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKey, Bytes>) throws
    {
        self.init(id: try bson[.id].decode(),
            lines: try bson[.lines].decode(as: BSON.BinaryView<Bytes.SubSequence>.self)
            {
                [UInt8].init($0.slice)
            })
    }
}
