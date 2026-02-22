import BSON
import MongoQL

extension Unidoc {
    public protocol PackagePageSegment<Item> {
        associatedtype Item: BSONDecodable & Sendable

        static func bridge(
            pipeline: inout Mongo.PipelineEncoder,
            limit: Int,
            skip: Int,
            from package: Mongo.AnyKeyPath,
            into output: Mongo.AnyKeyPath
        )
    }
}
