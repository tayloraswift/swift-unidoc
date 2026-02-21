import UnidocRecords

extension Unidoc.LinkerTables {
    /// A type that can generate ``Unidoc.Group`` identifiers.
    struct Next {
        private let base: Unidoc.Edition
        private var next: Counter

        init(base: Unidoc.Edition) {
            self.base = base
            self.next = .init()
        }
    }
}
extension Unidoc.LinkerTables.Next {
    mutating func callAsFunction(_ type: Unidoc.GroupType) -> Unidoc.Group {
        type.id(self.next(), in: self.base)
    }
}
