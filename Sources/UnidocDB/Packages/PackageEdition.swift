import BSONDecoding
import BSONEncoding
import MongoQL
import SemanticVersions
import SHA1
import Unidoc

@frozen public
struct PackageEdition:Identifiable, Equatable, Sendable
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
extension PackageEdition
{
    @inlinable public
    var package:Int32 { self.id.package }
    @inlinable public
    var version:Int32 { self.id.version }
}
extension PackageEdition:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case id = "_id"

        case package = "P"
        case version = "V"

        case release = "R"
        case patch = "A"

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

        /// Parses and returns this edition's refname as a semantic version. If the refname
        /// looks like a semantic version, this will strip leading `v`’s, and zero-extend the
        /// patch number.
        switch SemanticVersion.init(refname: self.name)
        {
        case .release(let version, build: _)?:
            bson[.release] = true
            bson[.patch] = version

        case .prerelease(let version, _, build: _)?:
            bson[.release] = false
            bson[.patch] = version

        case nil:
            break
        }

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
