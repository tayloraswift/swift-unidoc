extension Unidoc {
    @frozen public enum Citizenship: Equatable, Hashable, Comparable, Sendable {
        /// Something originates from the same culture as something else.
        case culture
        /// Something originates from the same package as something else.
        case package
        /// Something originates from a different package than something else.
        case foreign
    }
}
