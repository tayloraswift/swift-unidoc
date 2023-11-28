import BSONDecoding
import MongoQL
import UnidocDB
import UnidocRecords

extension Realm.EditionsQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        var prereleases:[Facet]
        public
        var releases:[Facet]
        public
        var package:Realm.Package

        @inlinable public
        init(prereleases:[Facet], releases:[Facet], package:Realm.Package)
        {
            self.prereleases = prereleases
            self.releases = releases
            self.package = package
        }
    }
}
extension Realm.EditionsQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case prereleases
        case releases
        case package
    }
}
extension Realm.EditionsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            prereleases: try bson[.prereleases]?.decode() ?? [],
            releases: try bson[.releases]?.decode() ?? [],
            package: try bson[.package].decode())
    }
}
