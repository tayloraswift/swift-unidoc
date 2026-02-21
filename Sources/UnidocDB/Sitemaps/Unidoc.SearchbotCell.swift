import BSON
import MongoQL
import UnidocAPI
import UnidocRecords
import UnixTime

extension Unidoc {
    @frozen public struct SearchbotCell: Identifiable, Sendable {
        public let id: ID

        /// The most-recent volume for which the associated page returned `200 OK`.
        public let ok: Edition

        public let bingbot: Crumb
        public let googlebot: Crumb
        public let yandexbot: Crumb

        @inlinable public init(
            id: ID,
            ok: Edition,
            bingbot: Crumb,
            googlebot: Crumb,
            yandexbot: Crumb
        ) {
            self.id = id
            self.ok = ok
            self.bingbot = bingbot
            self.googlebot = googlebot
            self.yandexbot = yandexbot
        }
    }
}
extension Unidoc.SearchbotCell: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable {
        case id = "_id"
        case ok = "V"
        case bingbot_fetches = "M"
        case bingbot_fetched = "MT"
        case googlebot_fetches = "G"
        case googlebot_fetched = "GT"
        case yandexbot_fetches = "Y"
        case yandexbot_fetched = "YT"
    }
}
extension Unidoc.SearchbotCell: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.id] = self.id
        bson[.ok] = self.ok

        bson[.bingbot_fetches] = self.bingbot.fetches
        bson[.bingbot_fetched] = self.bingbot.fetched

        bson[.googlebot_fetches] = self.googlebot.fetches
        bson[.googlebot_fetched] = self.googlebot.fetched

        bson[.yandexbot_fetches] = self.yandexbot.fetches
        bson[.yandexbot_fetched] = self.yandexbot.fetched
    }
}
extension Unidoc.SearchbotCell: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            id: try bson[.id].decode(),
            ok: try bson[.ok].decode(),
            bingbot: .init(
                fetched: try bson[.bingbot_fetched]?.decode(),
                fetches: try bson[.bingbot_fetches]?.decode()
            ),
            googlebot: .init(
                fetched: try bson[.googlebot_fetched]?.decode(),
                fetches: try bson[.googlebot_fetches]?.decode()
            ),
            yandexbot: .init(
                fetched: try bson[.yandexbot_fetched]?.decode(),
                fetches: try bson[.yandexbot_fetches]?.decode()
            )
        )
    }
}
