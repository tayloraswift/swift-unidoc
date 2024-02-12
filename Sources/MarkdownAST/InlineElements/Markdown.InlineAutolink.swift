import Sources

extension Markdown
{
    @frozen public
    struct InlineAutolink
    {
        /// Where in the markdown source text this autolink was parsed from.
        public
        let source:SourceReference<Markdown.Source>
        /// The text value of this autolink.
        public
        let text:String
        /// Indicates if this autolink originated from an inline code span.
        public
        let code:Bool

        @inlinable public
        init(source:SourceReference<Markdown.Source>, text:String, code:Bool)
        {
            self.source = source
            self.text = text
            self.code = code
        }
    }
}
extension Markdown.InlineAutolink
{
    @inlinable internal
    var element:Markdown.InlineElement
    {
        self.code ?
            .code(.init(text: text)) :
            .link(.init(source: self.source, url: self.text))
    }
}
