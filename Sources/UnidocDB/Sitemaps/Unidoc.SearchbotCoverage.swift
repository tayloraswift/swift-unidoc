import BSON
import MongoQL
import UnidocAPI
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct SearchbotCoverage:Identifiable, Sendable
    {
        public
        let id:SearchbotTrail

        /// The most-recent volume for which the associated page returned `200 OK`.
        public
        let ok:Edition

        public
        let bingbot:Int32
        public
        let googlebot:Int32
        public
        let yandexbot:Int32

        @inlinable public
        init(id:SearchbotTrail,
            ok:Edition,
            bingbot:Int32,
            googlebot:Int32,
            yandexbot:Int32)
        {
            self.id = id
            self.ok = ok
            self.bingbot = bingbot
            self.googlebot = googlebot
            self.yandexbot = yandexbot
        }
    }
}
extension Unidoc.SearchbotCoverage:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case ok = "V"
        case bingbot = "M"
        case googlebot = "G"
        case yandexbot = "Y"
    }
}
extension Unidoc.SearchbotCoverage:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.ok] = self.ok
        bson[.bingbot] = self.bingbot != 0 ? self.bingbot : nil
        bson[.googlebot] = self.googlebot != 0 ? self.googlebot : nil
        bson[.yandexbot] = self.yandexbot != 0 ? self.yandexbot : nil
    }
}
extension Unidoc.SearchbotCoverage:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            id: try bson[.id].decode(),
            ok: try bson[.ok].decode(),
            bingbot: try bson[.bingbot]?.decode() ?? 0,
            googlebot: try bson[.googlebot]?.decode() ?? 0,
            yandexbot: try bson[.yandexbot]?.decode() ?? 0)
    }
}
