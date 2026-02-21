import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc.ActivityQuery {
    @frozen public struct Output: Sendable {
        public let repo: [Unidoc.DB.RepoFeed.Activity]
        public let docs: [Unidoc.DB.DocsFeed.Activity<Unidoc.VolumeMetadata>]
        public var featured: [Featured<Unidoc.AnyVertex>]

        @inlinable init(
            repo: [Unidoc.DB.RepoFeed.Activity],
            docs: [Unidoc.DB.DocsFeed.Activity<Unidoc.VolumeMetadata>],
            featured: [Featured<Unidoc.AnyVertex>]
        ) {
            self.repo = repo
            self.docs = docs
            self.featured = featured
        }
    }
}
extension Unidoc.ActivityQuery.Output: Mongo.MasterCodingModel {
    public enum CodingKey: String, Sendable {
        case repo = "R"
        case docs = "D"
        case featured = "F"
    }
}
extension Unidoc.ActivityQuery.Output: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            repo: try bson[.repo].decode(),
            docs: try bson[.docs].decode(),
            featured: try bson[.featured].decode()
        )
    }
}
