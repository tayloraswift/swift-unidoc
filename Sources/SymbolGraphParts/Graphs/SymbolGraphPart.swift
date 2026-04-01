import JSONDecoding
import JSONParsing
import Symbols

@frozen public struct SymbolGraphPart: Identifiable, Equatable, Sendable {
    public let id: ID
    public let metadata: Metadata

    public var relationships: [Symbol.AnyRelationship]
    public var vertices: [Vertex]

    private init(
        id: ID,
        metadata: Metadata,
        relationships: [Symbol.AnyRelationship],
        vertices: [Vertex]
    ) {
        self.metadata = metadata
        self.id = id
        self.relationships = relationships
        self.vertices = vertices
    }
}
extension SymbolGraphPart {
    @inlinable public var culture: Symbol.Module { self.id.culture }
    @inlinable public var colony: Symbol.Module? { self.id.colony }
}
extension SymbolGraphPart {
    public init(json: JSON, id: ID) throws {
        try self.init(json: try JSON.Object.init(parsing: json), id: id)
    }

    private init(json: JSON.Object, id: ID) throws {
        enum CodingKey: String, Sendable {
            case metadata
            case vertices = "symbols"
            case relationships
        }

        // in 6.3, `module.name` became useless. so now we always use the filename as the
        // singular source of truth about what module symbols actually belong to.

        let json: JSON.ObjectDecoder<CodingKey> = try .init(indexing: json)
        self.init(
            id: id,
            metadata: try json[.metadata].decode(),
            relationships: try json[.relationships].decode(),
            vertices: try json[.vertices].decode()
        )
    }
}
