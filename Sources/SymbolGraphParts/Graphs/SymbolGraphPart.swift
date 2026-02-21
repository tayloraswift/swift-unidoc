import JSONDecoding
import JSONParsing
import Symbols

@frozen public struct SymbolGraphPart: Equatable, Sendable {
    public let metadata: Metadata
    public let culture: Symbol.Module
    public let colony: Symbol.Module?

    public var relationships: [Symbol.AnyRelationship]
    public var vertices: [Vertex]

    private init(
        metadata: Metadata,
        culture: Symbol.Module,
        colony: Symbol.Module?,
        relationships: [Symbol.AnyRelationship],
        vertices: [Vertex]
    ) {
        self.metadata = metadata
        self.culture = culture
        self.colony = colony
        self.relationships = relationships
        self.vertices = vertices
    }
}
extension SymbolGraphPart: Identifiable {
    @inlinable public var id: ID {
        .init(culture: self.culture, colony: self.colony)
    }
}
extension SymbolGraphPart {
    public init(json: JSON, id: ID) throws {
        try self.init(json: try JSON.Object.init(parsing: json), id: id)
    }

    private init(json: JSON.Object, id: ID) throws {
        enum CodingKey: String, Sendable {
            case metadata

            case module
            enum Module: String {
                case name
            }

            case vertices = "symbols"
            case relationships
        }

        let json: JSON.ObjectDecoder<CodingKey> = try .init(indexing: json)
        self.init(
            metadata: try json[.metadata].decode(),
            culture: try json[.module].decode(using: CodingKey.Module.self) {
                try $0[.name].decode()
            },
            colony: id.colony,
            relationships: try json[.relationships].decode(),
            vertices: try json[.vertices].decode()
        )

        if  self.culture != id.culture {
            throw IdentificationError.culture(id, expected: self.culture)
        }
    }
}
