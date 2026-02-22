import BSON
import MongoQL
import Unidoc
import UnidocRecords
import UnixTime

extension Unidoc.DB.DocsFeed {
    @frozen public struct Activity<Volume>: Identifiable, Sendable
        where   Volume: BSONEncodable,
        Volume: BSONDecodable,
        Volume: Sendable {
        /// In retrospect, this was a truly awful choice of `_id` key.
        public let id: UnixMillisecond

        public let volume: Volume

        @inlinable public init(discovered id: UnixMillisecond, volume: Volume) {
            self.id = id
            self.volume = volume
        }
    }
}
extension Unidoc.DB.DocsFeed.Activity: Mongo.MasterCodingModel {
    public enum CodingKey: String, Sendable {
        case id = "_id"
        case volume = "V"
    }
}
extension Unidoc.DB.DocsFeed.Activity: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.id] = self.id
        bson[.volume] = self.volume
    }
}
extension Unidoc.DB.DocsFeed.Activity: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(discovered: try bson[.id].decode(), volume: try bson[.volume].decode())
    }
}
