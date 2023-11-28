import BSONDecoding
import MongoQL
import UnidocRecords

extension Realm.EditionsQuery.Facet
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
extension Realm.EditionsQuery.Facet.Graphs:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case count
    }
}
extension Realm.EditionsQuery.Facet.Graphs:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(count: try bson[.count].decode())
    }
}
