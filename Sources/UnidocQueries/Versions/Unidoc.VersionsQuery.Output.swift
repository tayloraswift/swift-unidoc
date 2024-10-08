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
        var dependents:[Unidoc.PackageDependent]
        public
        var versions:[Unidoc.VersionState]
        public
        var branches:[Unidoc.VersionState]
        public
        var aliases:[Symbol.Package]
        public
        var pendingBuilds:[Unidoc.PendingBuild]
        public
        var recentBuilds:[Unidoc.CompleteBuild]
        public
        var realm:Unidoc.RealmMetadata?

        public
        var ticket:Unidoc.CrawlingTicket<Unidoc.Package>?
        public
        var user:Unidoc.User?

        @inlinable public
        init(
            package:Unidoc.PackageMetadata,
            dependents:[Unidoc.PackageDependent],
            versions:[Unidoc.VersionState],
            branches:[Unidoc.VersionState],
            aliases:[Symbol.Package],
            pendingBuilds:[Unidoc.PendingBuild],
            recentBuilds:[Unidoc.CompleteBuild],
            realm:Unidoc.RealmMetadata?,
            ticket:Unidoc.CrawlingTicket<Unidoc.Package>?,
            user:Unidoc.User?)
        {
            self.package = package
            self.dependents = dependents
            self.versions = versions
            self.branches = branches
            self.aliases = aliases
            self.ticket = ticket
            self.pendingBuilds = pendingBuilds
            self.recentBuilds = recentBuilds
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
        case pendingBuilds
        case recentBuilds
        case realm
        case ticket
        case user
    }
}
extension Unidoc.VersionsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(package: try bson[.package].decode(),
            dependents: try bson[.dependents].decode(),
            versions: try bson[.versions].decode(),
            branches: try bson[.branches].decode(),
            aliases: try bson[.aliases].decode(),
            pendingBuilds: try bson[.pendingBuilds]?.decode() ?? [],
            recentBuilds: try bson[.recentBuilds]?.decode() ?? [],
            realm: try bson[.realm]?.decode(),
            ticket: try bson[.ticket]?.decode(),
            user: try bson[.user]?.decode())
    }
}
