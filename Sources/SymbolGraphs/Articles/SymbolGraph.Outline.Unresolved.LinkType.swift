extension SymbolGraph.Outline.Unresolved {
    @frozen public enum LinkType: Equatable, Hashable, Sendable {
        /// The associated text is an unresolved doclink. The string does **not** include the
        /// `doc:` scheme.
        ///
        /// DEPRECATED in 0.10.0.
        case doc
        /// The associated text is an unresolved UCF expression.
        ///
        /// DEPRECATED in 0.10.0.
        case ucf
        /// The associated text is an untranslated URL. The string **includes** a scheme.
        case url
    }
}
