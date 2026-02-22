import MarkdownABI

extension SignatureSyntax {
    @frozen @usableFromInline internal enum Span {
        case text(Range<Int>, Markdown.Bytecode.Context? = nil, Depth? = nil)
        case wbr(indent: Bool)
    }
}
