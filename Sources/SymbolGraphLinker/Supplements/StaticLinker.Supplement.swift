import MarkdownAST
import MarkdownSemantics

extension StaticLinker
{
    @frozen public
    struct Supplement
    {
        public
        let headline:Headline?
        public
        let parsed:MarkdownDocumentation
        public
        let source:MarkdownSource

        @inlinable public
        init(headline:consuming Headline?,
            parsed:consuming MarkdownDocumentation,
            source:consuming MarkdownSource)
        {
            self.headline = headline
            self.parsed = parsed
            self.source = source
        }
    }
}
