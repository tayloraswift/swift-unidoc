import BSON
import MongoQL
import SemanticVersions
import SHA1
import SymbolGraphs
import Unidoc
import UnidocAPI
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct EditionMetadata:Identifiable, Equatable, Sendable
    {
        public
        let id:Edition

        /// Whether or not this edition is a release.
        public
        var series:VersionSeries?
        /// The patch version associated with this edition. This might not be
        /// trivially-computable from the ``name`` property, for example, `5.9.0` from
        /// `swift-5.9-RELEASE`.
        public
        var patch:PatchVersion

        /// The exact ref name associated with this edition.
        public
        var name:String
        /// The SHA-1 hash of the git commit associated with this edition.
        ///
        /// In production, this is virtually never nil, but the field is still nullable to
        /// support local use cases. The most common situation where this would be nil is when
        /// initializing the database with documentation for the standard library. The standard
        /// library is considered version-controlled (to support linking against it as a
        /// dependency), but its symbol graph can be generated without ever interacting with the
        /// official `/apple/swift` git repository.
        public
        var sha1:SHA1?

        @inlinable public
        init(id:Edition,
            series:VersionSeries?,
            patch:PatchVersion,
            name:String,
            sha1:SHA1?)
        {
            self.id = id

            self.series = series
            self.patch = patch

            self.name = name
            self.sha1 = sha1
        }
    }
}
extension Unidoc.EditionMetadata
{
    @inlinable public
    var package:Unidoc.Package { self.id.package }
    @inlinable public
    var version:Unidoc.Version { self.id.version }
}
extension Unidoc.EditionMetadata:Mongo.MasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"

        /// Duplicates the high 32 bits of the ``id`` property.
        case package = "p"
        /// Duplicates the low 32 bits of the ``id`` property.
        case version = "v"

        case series = "R"
        case patch = "A"

        case name = "T"
        case sha1 = "S"

        @available(*, deprecated, renamed: "series")
        @inlinable public static
        var release:Self { .series }
    }
}
extension Unidoc.EditionMetadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        bson[.package] = self.id.package
        bson[.version] = self.id.version

        bson[.series] = self.series
        bson[.patch] = self.patch

        bson[.name] = self.name
        bson[.sha1] = self.sha1
    }
}
extension Unidoc.EditionMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            series: try bson[.series]?.decode(),
            patch: try bson[.patch].decode(),
            name: try bson[.name].decode(),
            sha1: try bson[.sha1]?.decode())
    }
}
