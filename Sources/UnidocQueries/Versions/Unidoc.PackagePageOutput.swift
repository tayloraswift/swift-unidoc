import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc {
    @frozen public struct PackagePageOutput<Item> where Item: BSONDecodable {
        public let package: PackageMetadata
        public let list: [Item]
        public let user: Unidoc.User?

        @inlinable public init(package: PackageMetadata, list: [Item], user: User?) {
            self.package = package
            self.list = list
            self.user = user
        }
    }
}
extension Unidoc.PackagePageOutput: Sendable where Item: Sendable {
}
extension Unidoc.PackagePageOutput: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable {
        case package
        case list
        case user
    }
}
extension Unidoc.PackagePageOutput: BSONDocumentDecodable, BSONDecodable {
    public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            package: try bson[.package].decode(),
            list: try bson[.list].decode(),
            user: try bson[.user]?.decode()
        )
    }
}
