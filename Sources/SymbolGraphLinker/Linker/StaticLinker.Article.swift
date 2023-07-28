import MarkdownSemantics

extension StaticLinker
{
    struct Article
    {
        let standalone:Standalone?
        let source:MarkdownSource
        let body:MarkdownDocumentation

        init(standalone:Standalone?, source:MarkdownSource, body:MarkdownDocumentation)
        {
            self.standalone = standalone
            self.source = source
            self.body = body
        }
    }
}
