import JSON
import PackageGraphs
import SymbolGraphs

extension TargetNode {
    /// A helper type for decoding an array of dependencies.
    struct DependencyConditions {
        let platforms: [SymbolGraphMetadata.Platform]
        let traits: [SymbolGraphMetadata.Trait]

        private init(
            platforms: [SymbolGraphMetadata.Platform],
            traits: [SymbolGraphMetadata.Trait]
        ) {
            self.platforms = platforms
            self.traits = traits
        }
    }
}
extension TargetNode.DependencyConditions: JSONObjectDecodable {
    enum CodingKey: String, Sendable {
        case platformNames
        case traits
    }
    init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            platforms: try json[.platformNames].decode(),
            traits: try json[.traits]?.decode() ?? [],
        )
    }
}
