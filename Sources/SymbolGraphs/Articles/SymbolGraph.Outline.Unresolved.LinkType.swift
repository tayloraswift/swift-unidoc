extension SymbolGraph.Outline.Unresolved
{
    @frozen public
    enum LinkType:Equatable, Hashable, Sendable
    {
        /// The associated text is a doclink.
        case doc
        /// The associated text is a UCF expression.
        case ucf
        /// The associated text is a legacy Unidoc codelink expression.
        case unidocV3
    }
}
