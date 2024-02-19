import MarkdownSemantics

extension SSGC
{
    @frozen public
    struct Article
    {
        let standalone:Int32?
        let file:Int32
        let body:Markdown.SemanticDocument

        init(standalone:Int32?, file:Int32, body:Markdown.SemanticDocument)
        {
            self.standalone = standalone
            self.file = file
            self.body = body
        }
    }
}
