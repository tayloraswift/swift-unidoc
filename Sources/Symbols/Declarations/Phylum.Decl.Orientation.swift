extension Phylum.Decl {
    @frozen public enum Orientation: Equatable, Hashable, Comparable, Sendable {
        /// A declaration with a traditionally lowercased name, like `func foo`,
        /// a name that doesn’t fit into a lettercasing category, like `func +`,
        /// or no name at all, like `subscript(_:)`.
        ///
        /// *Gay* is not synonymous with *leaf*. For example, `associatedtype`s
        /// are leaf components, but they have ``straight`` orientation.
        case gay
        /// A declaration with a traditionally uppercased name, like `enum Foo`.
        case straight
    }
}
