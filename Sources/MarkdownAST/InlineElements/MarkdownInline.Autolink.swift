import Sources

extension MarkdownInline
{
    @frozen public
    struct Autolink
    {
        /// Where in the markdown source text this autolink was parsed from.
        public
        let source:SourceReference<MarkdownSource>
        /// The text value of this autolink.
        public
        let text:String
        /// Indicates if this autolink originated from an inline code span.
        public
        let code:Bool

        @inlinable public
        init(source:SourceReference<MarkdownSource>, text:String, code:Bool)
        {
            self.source = source
            self.text = text
            self.code = code
        }
    }
}
extension MarkdownInline.Autolink
{
    @inlinable internal
    var element:MarkdownInline.Block
    {
        self.code ?
            .code(.init(text: text)) :
            .link(.init(source: self.source, url: self.text))
    }
}
