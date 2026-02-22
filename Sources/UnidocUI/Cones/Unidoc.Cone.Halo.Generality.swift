extension Unidoc.Cone.Halo {
    enum Generality: Equatable, Hashable, Comparable, Sendable {
        /// No generic constraints.
        case unconstrained
        /// At least one generic constraint, but not enough to fully concretize the extension.
        case constrained
        /// Enough generic constraints to fully concretize the extension.
        case concretized
    }
}
