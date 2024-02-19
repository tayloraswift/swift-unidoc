import MarkdownAST
import MarkdownSemantics

extension SSGC
{
    @_spi(testable)
    @frozen public
    struct Supplement
    {
        public
        let type:Headline
        public
        let body:Markdown.SemanticDocument

        @inlinable public
        init(type:Headline, body:Markdown.SemanticDocument)
        {
            self.type = type
            self.body = body
        }
    }
}
