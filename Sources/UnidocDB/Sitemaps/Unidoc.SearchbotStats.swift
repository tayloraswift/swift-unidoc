import BSON
import MongoQL
import UnixTime

extension Unidoc
{
    @frozen public
    struct SearchbotStats:Identifiable, Sendable
    {
        public
        let id:Package
        public
        let harvested:UnixMillisecond

        public
        var bingbot:Counts
        public
        var googlebot:Counts
        public
        var yandexbot:Counts

        @inlinable public
        init(id:Package,
            harvested:UnixMillisecond,
            bingbot:Counts,
            googlebot:Counts,
            yandexbot:Counts)
        {
            self.id = id
            self.harvested = harvested

            self.bingbot = bingbot
            self.googlebot = googlebot
            self.yandexbot = yandexbot
        }
    }
}
extension Unidoc.SearchbotStats:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case harvested = "H"
        case bingbot = "B"
        case googlebot = "G"
        case yandexbot = "Y"
    }
}
extension Unidoc.SearchbotStats:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.harvested] = self.harvested
        bson[.bingbot] = self.bingbot
        bson[.googlebot] = self.googlebot
        bson[.yandexbot] = self.yandexbot
    }
}
extension Unidoc.SearchbotStats:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            harvested: try bson[.harvested].decode(),
            bingbot: try bson[.bingbot].decode(),
            googlebot: try bson[.googlebot].decode(),
            yandexbot: try bson[.yandexbot].decode())
    }
}
