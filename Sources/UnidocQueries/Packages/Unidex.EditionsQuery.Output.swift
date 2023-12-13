import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidex.EditionsQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        var prereleases:[Unidex.EditionOutput]
        public
        var releases:[Unidex.EditionOutput]
        public
        var package:Unidex.Package
        public
        var realm:Unidex.Realm?
        public
        var user:Unidex.User?

        @inlinable public
        init(prereleases:[Unidex.EditionOutput],
            releases:[Unidex.EditionOutput],
            package:Unidex.Package,
            realm:Unidex.Realm?,
            user:Unidex.User?)
        {
            self.prereleases = prereleases
            self.releases = releases
            self.package = package
            self.realm = realm
            self.user = user
        }
    }
}
extension Unidex.EditionsQuery.Output:MongoMasterCodingModel
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
extension Unidex.EditionsQuery.Output:BSONDocumentDecodable
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
