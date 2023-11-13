import BSONDecoding
import BSONEncoding
import MongoQL
import SemanticVersions
import SHA1
import SymbolGraphs
import Unidoc
import UnidocRecords

@available(*, deprecated, renamed: "Realm.Edition")
public
typealias PackageEdition = Realm.Edition

extension Realm
{
    @frozen public
    struct Edition:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Edition

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
        init(id:Unidoc.Edition,
            release:Bool,
            patch:PatchVersion,
            name:String,
            sha1:SHA1?,
            lost:Bool = false)
        {
            self.id = id

            self.release = release
            self.patch = patch

            self.name = name
            self.sha1 = sha1
            self.lost = lost
        }
    }
}
extension Realm.Edition
{
    @inlinable public
    var package:Int32 { self.id.package }
    @inlinable public
    var version:Int32 { self.id.version }
}
extension Realm.Edition:MongoMasterCodingModel
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
extension Realm.Edition:BSONDocumentEncodable
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
extension Realm.Edition:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            release: try bson[.release].decode(),
            patch: try bson[.patch].decode(),
            name: try bson[.name].decode(),
            sha1: try bson[.sha1]?.decode(),
            lost: try bson[.lost]?.decode() ?? false)
    }
}
