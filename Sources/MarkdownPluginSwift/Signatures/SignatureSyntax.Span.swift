import MarkdownABI

extension SignatureSyntax
{
    @frozen @usableFromInline internal
    enum Span
    {
        case text(Range<Int>, MarkdownBytecode.Context? = nil, Depth? = nil)
        case wbr(indent:Bool)
    }
}
