import BSONDecoding
import BSONEncoding
import Unidoc

extension Volume
{
    @frozen public
    struct TypeTree:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        var rows:[Noun]

        @inlinable public
        init(id:Unidoc.Scalar, rows:[Noun] = [])
        {
            self.id = id
            self.rows = rows
        }
    }
}
extension Volume.TypeTree
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case table = "T"
    }
}
extension Volume.TypeTree:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.table] = Volume.NounTable.init(eliding: self.rows)
    }
}
extension Volume.TypeTree:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            rows: try bson[.table]?.decode(as: Volume.NounTable.self, with: \.rows) ?? [])
    }
}
