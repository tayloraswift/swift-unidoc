import BSONDecoding
import BSONEncoding
import MongoQL

extension PackageDatabase.Packages
{
    struct Placement
    {
        let coordinate:Int32
        var repo:PackageRepo?
        var new:Bool

        init(coordinate:Int32, repo:PackageRepo?, new:Bool)
        {
            self.coordinate = coordinate
            self.new = new
        }
    }
}
extension PackageDatabase.Packages.Placement
{
    static
    var first:Self { .init(coordinate: 0, repo: nil, new: true) }
}
extension PackageDatabase.Packages.Placement:MongoMasterCodingModel
{
    enum CodingKey:String
    {
        case coordinate
        case repo
        case new
    }
}
extension PackageDatabase.Packages.Placement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            coordinate: try bson[.coordinate].decode(),
            repo: try bson[.repo]?.decode(),
            new: try bson[.new].decode())
    }
}

