import MarkdownSemantics

extension StaticLinker
{
    struct Supplement
    {
        let parsed:MarkdownSupplement
        let source:MarkdownSource

        init(parsed:MarkdownSupplement, source:MarkdownSource)
        {
            self.parsed = parsed
            self.source = source
        }
    }
}
