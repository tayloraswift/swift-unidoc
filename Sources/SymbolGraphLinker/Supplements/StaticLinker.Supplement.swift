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
        let parsed:Markdown.SemanticDocument
        public
        let source:MarkdownSource

        @inlinable public
        init(headline:consuming Headline?,
            parsed:consuming Markdown.SemanticDocument,
            source:consuming MarkdownSource)
        {
            self.headline = headline
            self.parsed = parsed
            self.source = source
        }
    }
}
