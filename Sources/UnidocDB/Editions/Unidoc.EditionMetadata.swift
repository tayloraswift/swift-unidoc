import BSON
import MongoQL
import SemanticVersions
import SHA1
import SymbolGraphs
import Unidoc
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
        var release:Bool
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

        public
        var build:BuildOutcome?

        @inlinable public
        init(id:Edition,
            release:Bool,
            patch:PatchVersion,
            name:String,
            sha1:SHA1?,
            build:BuildOutcome? = nil)
        {
            self.id = id

            self.release = release
            self.patch = patch

            self.name = name
            self.sha1 = sha1

            self.build = build
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
extension Unidoc.EditionMetadata:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"

        /// Duplicates the high 32 bits of the ``id`` property.
        case package = "p"
        /// Duplicates the low 32 bits of the ``id`` property.
        case version = "v"

        case release = "R"
        case patch = "A"

        case name = "T"
        case sha1 = "S"

        case failure = "F"
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

        bson[.release] = self.release
        bson[.patch] = self.patch

        bson[.name] = self.name
        bson[.sha1] = self.sha1

        switch self.build
        {
        case .failure(let failure): bson[.failure] = failure
        case nil:                   break
        }
    }
}
extension Unidoc.EditionMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            release: try bson[.release].decode(),
            patch: try bson[.patch].decode(),
            name: try bson[.name].decode(),
            sha1: try bson[.sha1]?.decode())

        if  let failure:Unidoc.BuildOutcome.Failure = try bson[.failure]?.decode()
        {
            self.build = .failure(failure)
        }
    }
}
