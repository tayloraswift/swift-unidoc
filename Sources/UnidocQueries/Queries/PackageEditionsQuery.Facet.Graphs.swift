import BSONDecoding
import MongoQL

extension PackageEditionsQuery.Facet
{
    @frozen public
    struct Graphs:Equatable, Sendable
    {
        public
        var count:Int

        @inlinable public
        init(count:Int)
        {
            self.count = count
        }
    }
}
extension PackageEditionsQuery.Facet.Graphs:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case count
    }
}
extension PackageEditionsQuery.Facet.Graphs:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(count: try bson[.count].decode())
    }
}
