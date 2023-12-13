import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc.EditionsQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        var prereleases:[Unidoc.EditionOutput]
        public
        var releases:[Unidoc.EditionOutput]
        public
        var package:Unidoc.PackageMetadata
        public
        var realm:Unidoc.RealmMetadata?
        public
        var user:Unidoc.User?

        @inlinable public
        init(prereleases:[Unidoc.EditionOutput],
            releases:[Unidoc.EditionOutput],
            package:Unidoc.PackageMetadata,
            realm:Unidoc.RealmMetadata?,
            user:Unidoc.User?)
        {
            self.prereleases = prereleases
            self.releases = releases
            self.package = package
            self.realm = realm
            self.user = user
        }
    }
}
extension Unidoc.EditionsQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case prereleases
        case releases
        case package
        case realm
        case user
    }
}
extension Unidoc.EditionsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            prereleases: try bson[.prereleases]?.decode() ?? [],
            releases: try bson[.releases]?.decode() ?? [],
            package: try bson[.package].decode(),
            realm: try bson[.realm]?.decode(),
            user: try bson[.user]?.decode())
    }
}
