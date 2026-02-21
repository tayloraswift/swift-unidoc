import BSON
import MongoQL
import UnidocAPI
import UnidocDB
import UnidocRecords

extension Unidoc {
    @frozen public struct VersionState: Equatable, Sendable {
        public var edition: EditionMetadata

        public var volume: VolumeMetadata?
        public var graph: Graph?

        @inlinable public init(
            edition: EditionMetadata,
            volume: VolumeMetadata?,
            graph: Graph?
        ) {
            self.edition = edition
            self.volume = volume
            self.graph = graph
        }
    }
}
extension Unidoc.VersionState: Mongo.MasterCodingModel {
    public enum CodingKey: String, Sendable {
        case edition
        case volume
        case graph
    }
}
extension Unidoc.VersionState: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(
            edition: try bson[.edition].decode(),
            volume: try bson[.volume]?.decode(),
            graph: try bson[.graph]?.decode()
        )
    }
}
