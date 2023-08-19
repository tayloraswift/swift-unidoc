import BSONDecoding
import BSONEncoding
import MD5
import UnidocRecords
import UnidocSelectors
import URI

extension Record
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
extension Record.SiteMap:Equatable where ID:Equatable
{
}
extension Record.SiteMap:Sendable where ID:Sendable
{
}
extension Record.SiteMap
{
    @frozen public
    enum CodingKey:String
    {
        case id = "_id"
        case lines = "L"
        case hash = "H"
    }
}
extension Record.SiteMap:BSONDocumentEncodable, BSONEncodable
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
extension Record.SiteMap:BSONDocumentDecodable, BSONDocumentViewDecodable, BSONDecodable
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
