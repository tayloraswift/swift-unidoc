import MarkdownSemantics

extension StaticLinker
{
    struct Article
    {
        let standalone:Int32?
        let source:MarkdownSource
        let body:MarkdownDocumentation

        init(standalone:Int32?, source:MarkdownSource, body:MarkdownDocumentation)
        {
            self.standalone = standalone
            self.source = source
            self.body = body
        }
    }
}
