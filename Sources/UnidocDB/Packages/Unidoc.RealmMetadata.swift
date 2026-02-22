import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc {
    @frozen public struct RealmMetadata: Identifiable, Equatable, Sendable {
        public let id: Realm

        public var symbol: String

        @inlinable public init(id: Realm, symbol: String) {
            self.id = id
            self.symbol = symbol
        }
    }
}
extension Unidoc.RealmMetadata: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable {
        case id = "_id"
        case symbol = "symbol"
    }
}
extension Unidoc.RealmMetadata: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.id] = self.id
        bson[.symbol] = self.symbol
    }
}
extension Unidoc.RealmMetadata: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(id: try bson[.id].decode(), symbol: try bson[.symbol].decode())
    }
}
