import BSON
import MongoQL
import UnidocRecords
import UnixTime

extension Unidoc {
    @frozen public struct BuildIdentifier: Equatable, Hashable, Sendable {
        public let edition: Unidoc.Edition
        public let run: UnixMillisecond

        @inlinable public init(edition: Unidoc.Edition, run: UnixMillisecond) {
            self.edition = edition
            self.run = run
        }
    }
}
extension Unidoc.BuildIdentifier: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable, BSONDecodable {
        case edition = "e"
        case run = "T"
    }
}
extension Unidoc.BuildIdentifier: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.edition] = self.edition
        bson[.run] = self.run
    }
}
extension Unidoc.BuildIdentifier: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(edition: try bson[.edition].decode(), run: try bson[.run].decode())
    }
}
