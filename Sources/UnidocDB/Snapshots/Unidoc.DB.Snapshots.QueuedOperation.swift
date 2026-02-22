import BSON
import UnidocAPI
import UnidocRecords

extension Unidoc.DB.Snapshots {
    @frozen public struct QueuedOperation: Equatable, Sendable {
        public let edition: Unidoc.Edition
        public let action: Unidoc.LinkerAction
        public let graphType: Unidoc.GraphType
        public let graphSize: Int64

        @inlinable init(
            edition: Unidoc.Edition,
            action: Unidoc.LinkerAction,
            graphType: Unidoc.GraphType,
            graphSize: Int64
        ) {
            self.edition = edition
            self.action = action
            self.graphType = graphType
            self.graphSize = graphSize
        }
    }
}
extension Unidoc.DB.Snapshots.QueuedOperation: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<Unidoc.Snapshot.CodingKey>) throws {
        self.init(
            edition: try bson[.id].decode(),
            action: try bson[.action].decode(),
            graphType: try bson[.type]?.decode() ?? .bson,
            graphSize: try bson[.size]?.decode() ?? 0
        )
    }
}
