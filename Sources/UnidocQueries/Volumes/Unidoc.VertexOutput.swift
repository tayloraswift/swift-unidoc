import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc {
    @frozen public struct VertexOutput: Sendable {
        public let matches: [AnyVertex]

        public let principalVolume: VolumeMetadata
        public let principalVertex: AnyVertex?
        public let principalGroups: [AnyGroup]

        public let canonicalVolume: VolumeMetadata?
        public let canonicalVertex: AnyVertex?

        public let adjacentPackages: [PackageMetadata]
        public let adjacentVertices: [AnyVertex]
        public let adjacentVolumes: [VolumeMetadata]


        public let coverage: SearchbotCell?
        public let tree: TypeTree?

        @inlinable public init(
            matches: [AnyVertex],
            principalVolume: VolumeMetadata,
            principalVertex: AnyVertex?,
            principalGroups: [AnyGroup],
            canonicalVolume: VolumeMetadata?,
            canonicalVertex: AnyVertex?,
            adjacentPackages: [PackageMetadata],
            adjacentVertices: [AnyVertex],
            adjacentVolumes: [VolumeMetadata],
            coverage: SearchbotCell?,
            tree: TypeTree?
        ) {
            self.matches = matches

            self.principalVolume = principalVolume
            self.principalVertex = principalVertex
            self.principalGroups = principalGroups

            self.canonicalVolume = canonicalVolume
            self.canonicalVertex = canonicalVertex

            self.adjacentPackages = adjacentPackages
            self.adjacentVertices = adjacentVertices
            self.adjacentVolumes = adjacentVolumes

            self.coverage = coverage
            self.tree = tree
        }
    }
}
extension Unidoc.VertexOutput: Mongo.MasterCodingModel {
    @frozen public enum CodingKey: String, Sendable {
        case matches

        case principalVolume
        case principalVertex
        case principalGroups

        case canonicalVolume
        case canonicalVertex

        case adjacentPackages
        case adjacentVertices
        case adjacentVolumes

        case coverage
        case tree
    }
}
extension Unidoc.VertexOutput: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            matches: try bson[.matches].decode(),
            principalVolume: try bson[.principalVolume].decode(),
            principalVertex: try bson[.principalVertex]?.decode(),
            principalGroups: try bson[.principalGroups]?.decode() ?? [],
            canonicalVolume: try bson[.canonicalVolume]?.decode(),
            canonicalVertex: try bson[.canonicalVertex]?.decode(),
            adjacentPackages: try bson[.adjacentPackages].decode(),
            adjacentVertices: try bson[.adjacentVertices].decode(),
            adjacentVolumes: try bson[.adjacentVolumes].decode(),
            coverage: try bson[.coverage]?.decode(),
            tree: try bson[.tree]?.decode()
        )
    }
}
