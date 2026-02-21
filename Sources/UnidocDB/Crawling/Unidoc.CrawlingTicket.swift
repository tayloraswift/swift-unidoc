import BSON
import GitHubAPI
import MongoQL
import UnidocRecords
import UnixTime

extension Unidoc {
    @frozen public struct CrawlingTicket<ID>: Identifiable, Sendable where ID: Hashable,
        ID: Sendable {
        public let id: ID
        public let node: GitHub.Node
        public var time: UnixMillisecond
        public var last: UnixMillisecond?

        @inlinable public init(
            id: ID,
            node: GitHub.Node,
            time: UnixMillisecond = .zero,
            last: UnixMillisecond? = nil
        ) {
            self.id = id
            self.node = node
            self.time = time
            self.last = last
        }
    }
}
extension Unidoc.CrawlingTicket: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable {
        case id = "_id"
        case node = "N"
        case time = "T"
        case last = "L"
    }
}
extension Unidoc.CrawlingTicket: BSONDocumentEncodable, BSONEncodable where ID: BSONEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.id] = self.id
        bson[.node] = self.node
        bson[.time] = self.time
        bson[.last] = self.last
    }
}
extension Unidoc.CrawlingTicket: BSONDocumentDecodable, BSONDecodable where ID: BSONDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            id: try bson[.id].decode(),
            node: try bson[.node].decode(),
            time: try bson[.time].decode(),
            last: try bson[.last]?.decode()
        )
    }
}
