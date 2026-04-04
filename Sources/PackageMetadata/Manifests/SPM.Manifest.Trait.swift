import JSON
import SymbolGraphs

extension SPM.Manifest {
    @frozen public struct Trait: Equatable, Sendable {
        public let id: SymbolGraphMetadata.Trait
        public let implied: [SymbolGraphMetadata.Trait]

        @inlinable init(
            id: SymbolGraphMetadata.Trait,
            implied: [SymbolGraphMetadata.Trait]
        ) {
            self.id = id
            self.implied = implied
        }
    }
}
extension SPM.Manifest.Trait: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case name
        case enabledTraits
    }
    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            id: try json[.name].decode(),
            implied: try json[.enabledTraits].decode()
        )
    }
}
