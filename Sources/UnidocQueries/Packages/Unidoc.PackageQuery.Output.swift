import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc.PackageQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        var prereleases:[Tag]
        public
        var releases:[Tag]
        public
        var tagless:Tagless?
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
            package:Unidoc.PackageMetadata,
            realm:Unidoc.RealmMetadata?,
            user:Unidoc.User?)
        {
            self.prereleases = prereleases
            self.releases = releases
            self.tagless = tagless
            self.package = package
            self.realm = realm
            self.user = user
        }
    }
}
extension Unidoc.PackageQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case prereleases
        case releases
        case tagless_volume
        case tagless_graph
        case package
        case realm
        case user
    }
}
extension Unidoc.PackageQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let tagless:Unidoc.PackageQuery.Graph? = try bson[.tagless_graph]?.decode()
        self.init(
            prereleases: try bson[.prereleases]?.decode() ?? [],
            releases: try bson[.releases]?.decode() ?? [],
            tagless: try tagless.map
            {
                .init(volume: try bson[.tagless_volume]?.decode(), graph: $0)
            },
            package: try bson[.package].decode(),
            realm: try bson[.realm]?.decode(),
            user: try bson[.user]?.decode())
    }
}
