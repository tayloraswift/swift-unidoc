import BSONDecoding
import BSONEncoding
import MongoQL
import UnidocRecords

extension UnidocDatabase.Packages
{
    struct Placement
    {
        let coordinate:Int32
        let realm:Realm?
        var repo:Realm.Repo?
        var new:Bool

        init(coordinate:Int32, realm:Realm?, repo:Realm.Repo?, new:Bool)
        {
            self.coordinate = coordinate
            self.realm = realm
            self.repo = repo
            self.new = new
        }
    }
}
extension UnidocDatabase.Packages.Placement
{
    static
    var first:Self { .init(coordinate: 0, realm: nil, repo: nil, new: true) }
}
extension UnidocDatabase.Packages.Placement:MongoMasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case coordinate
        case realm
        case repo
        case new
    }
}
extension UnidocDatabase.Packages.Placement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            coordinate: try bson[.coordinate].decode(),
            realm: try bson[.realm]?.decode(),
            repo: try bson[.repo]?.decode(),
            new: try bson[.new].decode())
    }
}
