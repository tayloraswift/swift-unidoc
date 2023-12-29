import BSON
import MongoQL

extension Unidoc
{
    @frozen public
    struct CrawlingWindow:Identifiable
    {
        public
        let id:BSON.Millisecond
        public
        var crawled:BSON.Millisecond?

        @inlinable public
        init(id:BSON.Millisecond, crawled:BSON.Millisecond? = nil)
        {
            self.id = id
            self.crawled = crawled
        }
    }
}
extension Unidoc.CrawlingWindow:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case crawled = "T"
    }
}
extension Unidoc.CrawlingWindow:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.crawled] = self.crawled
    }
}
extension Unidoc.CrawlingWindow:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), crawled: try bson[.crawled]?.decode())
    }
}
