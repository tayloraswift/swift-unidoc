import SymbolGraphs

extension TargetNode {
    @frozen public struct DependencyIterator<Element> where Element: Hashable {
        @usableFromInline internal let platform: SymbolGraphMetadata.Platform
        @usableFromInline internal var base: IndexingIterator<[Dependency<Element>]>

        @inlinable internal init(
            platform: SymbolGraphMetadata.Platform,
            base: IndexingIterator<[Dependency<Element>]>
        ) {
            self.platform = platform
            self.base = base
        }
    }
}
extension TargetNode.DependencyIterator: IteratorProtocol {
    @inlinable public mutating func next() -> Element? {
        while let dependency: TargetNode.Dependency<Element> = self.base.next() {
            if  dependency.platforms.isEmpty || dependency.platforms.contains(self.platform) {
                return dependency.id
            }
        }
        return nil
    }
}
