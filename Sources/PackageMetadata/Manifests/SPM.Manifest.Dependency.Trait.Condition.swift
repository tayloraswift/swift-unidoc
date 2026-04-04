import JSON
import SymbolGraphs

extension SPM.Manifest.Dependency.Trait {
    /// A helper type for decoding an array of dependencies.
    @frozen public struct Condition: Equatable, Sendable {
        public let traits: [SymbolGraphMetadata.Trait]
    }
}
extension SPM.Manifest.Dependency.Trait.Condition: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case traits
    }
    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(traits: try json[.traits]?.decode() ?? [])
    }
}
