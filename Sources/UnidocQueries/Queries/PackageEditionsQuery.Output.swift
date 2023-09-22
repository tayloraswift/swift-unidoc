import BSONDecoding
import MongoQL
import UnidocDB

extension PackageEditionsQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        var prereleases:[Facet]
        public
        var releases:[Facet]
        public
        var record:PackageRecord

        @inlinable public
        init(prereleases:[Facet], releases:[Facet], record:PackageRecord)
        {
            self.prereleases = prereleases
            self.releases = releases
            self.record = record
        }
    }
}
extension PackageEditionsQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String
    {
        case prereleases
        case releases
        case record
    }
}
extension PackageEditionsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            prereleases: try bson[.prereleases].decode(),
            releases: try bson[.releases].decode(),
            record: try bson[.record].decode())
    }
}
