import SymbolGraphs

extension TargetNode {
    @frozen public struct Dependency<ID>: Identifiable, Equatable, Hashable where ID: Hashable {
        public let id: ID
        public let platforms: [SymbolGraphMetadata.Platform]
        public let traits: [SymbolGraphMetadata.Trait]

        @inlinable public init(
            id: ID,
            platforms: [SymbolGraphMetadata.Platform] = [],
            traits: [SymbolGraphMetadata.Trait] = []
        ) {
            self.id = id
            self.platforms = platforms
            self.traits = traits
        }
    }
}
extension TargetNode.Dependency: Sendable where ID: Sendable {}
