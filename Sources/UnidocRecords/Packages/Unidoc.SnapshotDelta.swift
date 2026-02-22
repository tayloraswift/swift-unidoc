import BSON
import SemanticVersions
import SymbolGraphs
import UnidocAPI

extension Unidoc {
    @frozen public struct SnapshotDelta: Equatable, Sendable {
        public let metadata: SymbolGraphMetadata?
        public let action: LinkerAction?
        public let swift: PatchVersion?
        public let type: GraphType?
        public let size: Int64?

        @inlinable public init(
            metadata: SymbolGraphMetadata?,
            action: LinkerAction?,
            swift: PatchVersion?,
            type: GraphType?,
            size: Int64?
        ) {
            self.metadata = metadata
            self.action = action
            self.swift = swift
            self.type = type
            self.size = size
        }
    }
}
extension Unidoc.SnapshotDelta: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<Unidoc.Snapshot.CodingKey>) throws {
        self.init(
            metadata: try bson[.metadata]?.decode(),
            action: try bson[.action]?.decode(),
            swift: try bson[.swift]?.decode(),
            type: try bson[.type]?.decode(),
            size: try bson[.size]?.decode()
        )
    }
}
