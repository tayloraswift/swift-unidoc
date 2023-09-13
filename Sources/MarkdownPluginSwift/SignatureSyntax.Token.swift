import MarkdownABI

extension SignatureSyntax
{
    @frozen @usableFromInline internal
    struct Token
    {
        @usableFromInline internal
        let range:Range<Int>
        @usableFromInline internal
        let color:MarkdownBytecode.Context?

        init(range:Range<Int>, color:MarkdownBytecode.Context?)
        {
            self.range = range
            self.color = color
        }
    }
}
extension SignatureSyntax.Token
{
    @inlinable internal
    var start:Int { self.range.startIndex }
}
