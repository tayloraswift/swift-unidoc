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
        var prereleases:[Tag]
        public
        var releases:[Tag]
        public
        var tagless:Tagless?
        public
        var aliases:[Symbol.Package]
        public
        var package:Unidoc.PackageMetadata
        public
        var realm:Unidoc.RealmMetadata?
        public
        var user:Unidoc.User?

        @inlinable public
        init(prereleases:[Tag],
            releases:[Tag],
            tagless:Tagless?,
            aliases:[Symbol.Package],
            package:Unidoc.PackageMetadata,
            realm:Unidoc.RealmMetadata?,
            user:Unidoc.User?)
        {
            self.prereleases = prereleases
            self.releases = releases
            self.tagless = tagless
            self.aliases = aliases
            self.package = package
            self.realm = realm
            self.user = user
        }
    }
}
extension Unidoc.VersionsQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case prereleases
        case releases
        case tagless_volume
        case tagless_graph
        case aliases
        case package
        case realm
        case user
    }
}
extension Unidoc.VersionsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let tagless:Unidoc.VersionsQuery.Graph? = try bson[.tagless_graph]?.decode()
        self.init(
            prereleases: try bson[.prereleases]?.decode() ?? [],
            releases: try bson[.releases]?.decode() ?? [],
            tagless: try tagless.map
            {
                .init(volume: try bson[.tagless_volume]?.decode(), graph: $0)
            },
            aliases: try bson[.aliases]?.decode() ?? [],
            package: try bson[.package].decode(),
            realm: try bson[.realm]?.decode(),
            user: try bson[.user]?.decode())
    }
}
