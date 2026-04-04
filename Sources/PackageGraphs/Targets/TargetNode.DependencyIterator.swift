import SymbolGraphs

extension TargetNode {
    @frozen public struct DependencyIterator<Element> where Element: Hashable {
        @usableFromInline let platform: SymbolGraphMetadata.Platform
        @usableFromInline let traits: Set<SymbolGraphMetadata.Trait>
        @usableFromInline var base: IndexingIterator<[Dependency<Element>]>

        @inlinable init(
            platform: SymbolGraphMetadata.Platform,
            traits: Set<SymbolGraphMetadata.Trait>,
            base: IndexingIterator<[Dependency<Element>]>
        ) {
            self.platform = platform
            self.traits = traits
            self.base = base
        }
    }
}
extension TargetNode.DependencyIterator: IteratorProtocol {
    @inlinable public mutating func next() -> Element? {
        while let dependency: TargetNode.Dependency<Element> = self.base.next() {
            if  dependency.platforms.isEmpty || dependency.platforms.contains(self.platform),
                dependency.traits.allSatisfy(self.traits.contains(_:)) {
                return dependency.id
            }
        }
        return nil
    }
}
