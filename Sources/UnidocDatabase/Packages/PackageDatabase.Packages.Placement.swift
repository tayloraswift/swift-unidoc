import BSONDecoding
import BSONEncoding
import MongoQL

extension PackageDatabase.Packages
{
    struct Placement
    {
        let cell:Int32
        var repo:PackageRepo?
        var new:Bool

        init(cell:Int32, repo:PackageRepo?, new:Bool)
        {
            self.cell = cell
            self.new = new
        }
    }
}
extension PackageDatabase.Packages.Placement
{
    static
    var first:Self { .init(cell: 0, repo: nil, new: true) }
}
extension PackageDatabase.Packages.Placement:MongoMasterCodingModel
{
    enum CodingKey:String
    {
        case cell
        case repo
        case new
    }
}
extension PackageDatabase.Packages.Placement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            cell: try bson[.cell].decode(),
            repo: try bson[.repo]?.decode(),
            new: try bson[.new].decode())
    }
}

