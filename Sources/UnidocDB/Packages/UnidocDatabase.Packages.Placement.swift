import BSONDecoding
import BSONEncoding
import MongoQL

extension UnidocDatabase.Packages
{
    struct Placement
    {
        let coordinate:Int32
        var repo:PackageRepo?
        var new:Bool

        init(coordinate:Int32, repo:PackageRepo?, new:Bool)
        {
            self.coordinate = coordinate
            self.repo = repo
            self.new = new
        }
    }
}
extension UnidocDatabase.Packages.Placement
{
    static
    var first:Self { .init(coordinate: 0, repo: nil, new: true) }
}
extension UnidocDatabase.Packages.Placement:MongoMasterCodingModel
{
    enum CodingKey:String
    {
        case coordinate
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
            repo: try bson[.repo]?.decode(),
            new: try bson[.new].decode())
    }
}

