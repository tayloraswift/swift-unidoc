import BSON
import Unidoc

extension Unidoc
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
extension Unidoc.TypeTree
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case table = "T"
    }
}
extension Unidoc.TypeTree:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.table] = Volume.NounTable.init(eliding: self.rows)
    }
}
extension Unidoc.TypeTree:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            rows: try bson[.table]?.decode(as: Volume.NounTable.self, with: \.rows) ?? [])
    }
}
