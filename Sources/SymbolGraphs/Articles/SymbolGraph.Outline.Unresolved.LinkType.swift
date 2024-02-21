extension SymbolGraph.Outline.Unresolved
{
    @frozen public
    enum LinkType:Equatable, Hashable, Sendable
    {
        /// The associated text is an unresolved doclink.
        case doc
        /// The associated text is an untranslated web URL. The string does **not** include a
        /// scheme.
        case web
        /// The associated text is an unresolved UCF expression.
        case ucf
        /// The associated text is a legacy Unidoc codelink expression.
        case unidocV3
    }
}
