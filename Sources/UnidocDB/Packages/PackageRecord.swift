import BSONDecoding
import BSONEncoding
import ModuleGraphs
import MongoQL
import SymbolGraphs

@frozen public
struct PackageRecord:Identifiable, Equatable, Sendable
{
    public
    let id:PackageIdentifier
    /// The cell-number this package was assigned. Cell numbers can be positive or negative,
    /// but packages that track remote repositories will always have positive cell numbers.
    public
    let cell:Int32
    /// The repo this package tracks. Currently only GitHub repos are supported.
    public
    var repo:PackageRepo?

    @inlinable public
    init(id:PackageIdentifier, cell:Int32, repo:PackageRepo? = nil)
    {
        self.id = id
        self.cell = cell
        self.repo = repo
    }
}
extension PackageRecord:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String
    {
        case id = "_id"
        case cell = "P"
        case repo = "R"
    }
}
extension PackageRecord:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.cell] = self.cell
        bson[.repo] = self.repo
    }
}
extension PackageRecord:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            cell: try bson[.cell].decode(),
            repo: try bson[.repo]?.decode())
    }
}
