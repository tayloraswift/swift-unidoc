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

    /// Whether or not this edition is a release.
    public
    var release:Bool
    /// The patch version associated with this edition. This might not be trivially-computable
    /// from the ``name`` property, for example, `5.9.0` from `swift-5.9-RELEASE`.
    public
    var patch:PatchVersion

    /// The exact ref name associated with this edition.
    public
    var name:String
    /// The SHA-1 hash of the git commit associated with this edition.
    public
    var sha1:SHA1?
    /// Indicates if the repository host has published a tag of the same name with a different
    /// ``sha1`` hash.
    public
    var lost:Bool

    @inlinable public
    init(id:Unidoc.Zone,
        release:Bool?,
        patch:PatchVersion?,
        name:String,
        sha1:SHA1?,
        lost:Bool = false)
    {
        self.id = id

        //  Temporary HACK until we can migrate all the database records.
        self.release = release ?? true
        if  let patch:PatchVersion
        {
            self.patch = patch
        }
        else if name == "swift-5.8.1-RELEASE"
        {
            self.patch = .v(5, 8, 1)
        }
        else if name == "swift-5.9-RELEASE"
        {
            self.patch = .v(5, 9, 0)
        }
        else
        {
            switch SemanticVersion.init(refname: name)
            {
            case .release(let version, build: _)?:
                self.release = true
                self.patch = version

            case .prerelease(let version, _, build: _)?:
                self.release = false
                self.patch = version

            case nil:
                fatalError("can’t infer patch version from refname: \(name)")
            }
        }
        //  End temporary HACK.

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

        bson[.release] = self.release
        bson[.patch] = self.patch

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
            release: try bson[.release]?.decode(),
            patch: try bson[.patch]?.decode(),
            name: try bson[.name].decode(),
            sha1: try bson[.sha1]?.decode(),
            lost: try bson[.lost]?.decode() ?? false)
    }
}
