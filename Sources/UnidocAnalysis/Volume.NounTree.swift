import BSONDecoding
import BSONEncoding
import Unidoc
import UnidocRecords

extension Volume
{
    @frozen public
    struct NounTree:Identifiable, Equatable, Sendable
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
extension Volume.NounTree
{
    @inlinable internal
    init(id:Unidoc.Scalar, table:Table)
    {
        self.init(id: id, rows: table.rows)
    }

    var table:Table { .init(rows: self.rows) }
}
extension Volume.NounTree
{
    public
    enum CodingKey:String
    {
        case id = "_id"
        case table = "T"
    }
}
extension Volume.NounTree:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.table] = self.table
    }
}
extension Volume.NounTree:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), table: try bson[.table].decode())
    }
}