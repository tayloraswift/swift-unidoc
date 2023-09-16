import BSONDecoding
import MongoQL
import UnidocDB

extension PackageEditionsQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        var record:PackageRecord
        public
        var facets:[Facet]

        @inlinable public
        init(record:PackageRecord, facets:[Facet])
        {
            self.record = record
            self.facets = facets
        }
    }
}
extension PackageEditionsQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String
    {
        case record
        case facets
    }
}
extension PackageEditionsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(record: try bson[.record].decode(), facets: try bson[.facets].decode())
    }
}
