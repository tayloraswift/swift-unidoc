import MarkdownSemantics

extension StaticLinker
{
    struct Article
    {
        let standalone:Int32?
        let file:Int32
        let body:MarkdownDocumentation

        init(standalone:Int32?, file:Int32, body:MarkdownDocumentation)
        {
            self.standalone = standalone
            self.file = file
            self.body = body
        }
    }
}
