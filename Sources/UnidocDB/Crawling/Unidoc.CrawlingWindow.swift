import BSON
import MongoQL
import UnixTime

extension Unidoc
{
    @frozen public
    struct CrawlingWindow:Identifiable
    {
        public
        let id:UnixMillisecond
        public
        var crawled:UnixMillisecond?
        public
        var expires:UnixMillisecond

        @inlinable public
        init(id:UnixMillisecond,
            crawled:UnixMillisecond? = nil,
            expires:UnixMillisecond = .zero)
        {
            self.id = id
            self.crawled = crawled
            self.expires = expires
        }
    }
}
extension Unidoc.CrawlingWindow:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case crawled = "C"
        case expires = "T"
    }
}
extension Unidoc.CrawlingWindow:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.crawled] = self.crawled
        bson[.expires] = self.expires
    }
}
extension Unidoc.CrawlingWindow:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            crawled: try bson[.crawled]?.decode(),
            expires: try bson[.expires]?.decode() ?? .zero)
    }
}
