extension Sequence where Element: Identifiable, Element.ID: Comparable {
    @inlinable public func sortedTopologically(
        by edges: some Sequence<(Element.ID, Element.ID)>
    ) -> [Element]? {
        let index: [Element.ID: Element] = self.reduce(into: [:]) { $0[$1.id] = $1 }
        return index.orderingValuesTopologically(by: edges)
    }
}
