import SymbolGraphs

extension TargetNode {
    @frozen public struct DependencyView<Element> where Element: Hashable {
        @usableFromInline let platform: SymbolGraphMetadata.Platform
        @usableFromInline let traits: Set<SymbolGraphMetadata.Trait>
        @usableFromInline let base: [Dependency<Element>]

        @inlinable init(
            platform: SymbolGraphMetadata.Platform,
            traits: Set<SymbolGraphMetadata.Trait>,
            base: [Dependency<Element>]
        ) {
            self.platform = platform
            self.traits = traits
            self.base = base
        }
    }
}
extension TargetNode.DependencyView: Sequence {
    @inlinable public func makeIterator() -> TargetNode.DependencyIterator<Element> {
        .init(platform: self.platform, traits: self.traits, base: self.base.makeIterator())
    }
}
