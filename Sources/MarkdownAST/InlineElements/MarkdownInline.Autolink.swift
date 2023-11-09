import Sources

extension MarkdownInline
{
    @frozen public
    struct Autolink
    {
        /// Where in the markdown source text this autolink was parsed from, if known.
        public
        let source:SourceReference<Int>?
        /// Indicates if this autolink originated from an inline code span.
        public
        let code:Bool
        /// The text value of this autolink.
        public
        let text:String

        @inlinable public
        init(_ text:String, code:Bool, source:SourceReference<Int>?)
        {
            self.source = source
            self.code = code
            self.text = text
        }
    }
}
extension MarkdownInline.Autolink
{
    @inlinable internal
    var element:MarkdownInline.Block
    {
        self.code ? .code(.init(text: text)) : .link(.init(url: self.text))
    }
}
