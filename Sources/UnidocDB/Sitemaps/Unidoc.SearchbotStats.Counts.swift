import BSON
import MongoQL

extension Unidoc.SearchbotStats {
    @frozen public struct Counts {
        /// Pages that no longer exist in the latest version of the package’s documentation,
        /// but were indexed by the relevant search engine at some point in the past.
        public var historical: Int
        /// Pages that are present in the latest version of the package’s documentation, and
        /// have not been crawled by the relevant search engine.
        public var pending: Int
        /// Pages that are present in the latest version of the package’s documentation, and
        /// have been crawled by the relevant search engine.
        public var crawled: Int

        @inlinable public init(historical: Int = 0, pending: Int = 0, crawled: Int = 0) {
            self.historical = historical
            self.pending = pending
            self.crawled = crawled
        }
    }
}
extension Unidoc.SearchbotStats.Counts: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable {
        case historical = "H"
        case pending = "P"
        case crawled = "C"
    }
}
extension Unidoc.SearchbotStats.Counts: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.historical] = self.historical
        bson[.pending] = self.pending
        bson[.crawled] = self.crawled
    }
}
extension Unidoc.SearchbotStats.Counts: BSONDocumentDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            historical: try bson[.historical].decode(),
            pending: try bson[.pending].decode(),
            crawled: try bson[.crawled].decode()
        )
    }
}
