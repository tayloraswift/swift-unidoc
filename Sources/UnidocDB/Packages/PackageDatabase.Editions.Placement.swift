import BSONDecoding
import BSONEncoding
import MongoQL
import SHA1

extension PackageDatabase.Editions
{
    struct Placement
    {
        let coordinate:Int32
        let sha1:SHA1?
        let new:Bool

        init(coordinate:Int32, sha1:SHA1?, new:Bool)
        {
            self.coordinate = coordinate
            self.sha1 = sha1
            self.new = new
        }
    }
}
extension PackageDatabase.Editions.Placement
{
    static
    var first:Self { .init(coordinate: 0, sha1: nil, new: true) }
}
extension PackageDatabase.Editions.Placement:MongoMasterCodingModel
{
    enum CodingKey:String
    {
        case coordinate
        case sha1
        case new
    }
}
extension PackageDatabase.Editions.Placement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(coordinate: try bson[.coordinate].decode(),
            sha1: try bson[.sha1]?.decode(),
            new: try bson[.new].decode())
    }
}
