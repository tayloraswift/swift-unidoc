import BSON
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc.VersionsQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        var package:Unidoc.PackageMetadata
        public
        var dependents:[Unidoc.PackageDependency]
        public
        var versions:[Unidoc.VersionState]
        public
        var branches:[Unidoc.VersionState]
        public
        var aliases:[Symbol.Package]

        public
        var build:Unidoc.BuildMetadata?
        public
        var realm:Unidoc.RealmMetadata?
        public
        var user:Unidoc.User?

        @inlinable public
        init(
            package:Unidoc.PackageMetadata,
            dependents:[Unidoc.PackageDependency],
            versions:[Unidoc.VersionState],
            branches:[Unidoc.VersionState],
            aliases:[Symbol.Package],
            build:Unidoc.BuildMetadata?,
            realm:Unidoc.RealmMetadata?,
            user:Unidoc.User?)
        {
            self.package = package
            self.dependents = dependents
            self.versions = versions
            self.branches = branches
            self.aliases = aliases
            self.build = build
            self.realm = realm
            self.user = user
        }
    }
}
extension Unidoc.VersionsQuery.Output:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case versions
        case dependents
        case branches
        case aliases
        case package
        case build
        case realm
        case user
    }
}
extension Unidoc.VersionsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(package: try bson[.package].decode(),
            dependents: try bson[.dependents]?.decode() ?? [],
            versions: try bson[.versions]?.decode() ?? [],
            branches: try bson[.branches]?.decode() ?? [],
            aliases: try bson[.aliases]?.decode() ?? [],
            build: try bson[.build]?.decode(),
            realm: try bson[.realm]?.decode(),
            user: try bson[.user]?.decode())
    }
}
