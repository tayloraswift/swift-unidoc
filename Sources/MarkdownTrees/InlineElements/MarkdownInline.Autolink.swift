import Sources

extension MarkdownInline
{
    @frozen public
    struct Autolink
    {
        public
        let expression:Expression
        public
        let source:SourceText<Int>?

        @inlinable public
        init(_ expression:Expression, source:SourceText<Int>?)
        {
            self.expression = expression
            self.source = source
        }
    }
}
