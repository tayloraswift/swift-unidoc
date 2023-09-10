import BSONDecoding
import BSONEncoding
import MongoQL
import SHA1

extension PackageDatabase.Editions
{
    struct Placement
    {
        let cell:Int32
        let sha1:SHA1?

        init(cell:Int32, sha1:SHA1?)
        {
            self.cell = cell
            self.sha1 = sha1
        }
    }
}
extension PackageDatabase.Editions.Placement
{
    static
    var first:Self { .init(cell: 0, sha1: nil) }
}
extension PackageDatabase.Editions.Placement:MongoMasterCodingModel
{
    enum CodingKey:String
    {
        case cell
        case sha1
    }
}
extension PackageDatabase.Editions.Placement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(cell: try bson[.cell].decode(), sha1: try bson[.sha1]?.decode())
    }
}
