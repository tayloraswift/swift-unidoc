import JSON
import SymbolGraphs

extension SPM.Manifest.Dependency {
    @frozen public struct Trait: Equatable, Sendable {
        public let id: SymbolGraphMetadata.Trait
        public let condition: Condition

        @inlinable public init(id: SymbolGraphMetadata.Trait, condition: Condition) {
            self.id = id
            self.condition = condition
        }
    }
}
extension SPM.Manifest.Dependency.Trait: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case name
        case condition
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            id: try json[.name].decode(),
            condition: try json[.condition]?.decode() ?? .init(traits: [])
        )
    }
}
