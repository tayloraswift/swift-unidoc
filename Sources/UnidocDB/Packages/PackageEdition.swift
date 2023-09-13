import BSONDecoding
import BSONEncoding
import MongoQL
import SHA1
import Unidoc

@frozen public
struct PackageEdition:Identifiable
{
    public
    let id:Unidoc.Zone

    /// The exact ref name associated with this edition.
    public
    let name:String
    /// The SHA-1 hash of the git commit associated with this edition.
    public
    let sha1:SHA1?
    /// Indicates if the repository host has published a tag of the same name with a different
    /// ``sha1`` hash.
    public
    let lost:Bool

    @inlinable public
    init(id:Unidoc.Zone, name:String, sha1:SHA1?, lost:Bool = false)
    {
        self.id = id
        self.name = name
        self.sha1 = sha1
        self.lost = lost
    }
}
extension PackageEdition:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case id = "_id"

        case package = "P"
        case version = "V"

        case name = "T"
        case sha1 = "S"
        case lost = "L"
    }
}
extension PackageEdition:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        bson[.package] = self.id.package
        bson[.version] = self.id.version

        bson[.name] = self.name
        bson[.sha1] = self.sha1
        bson[.lost] = self.lost ? true : nil
    }
}
extension PackageEdition:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            name: try bson[.name].decode(),
            sha1: try bson[.sha1]?.decode(),
            lost: try bson[.lost]?.decode() ?? false)
    }
}