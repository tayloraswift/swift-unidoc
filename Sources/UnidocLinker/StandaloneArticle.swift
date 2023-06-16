import MarkdownSemantics

struct StandaloneArticle
{
    let markdown:MarkdownDocumentationSupplement
    let address:Int32
    let file:Int32
    let text:String

    init(markdown:MarkdownDocumentationSupplement,
        address:Int32,
        file:Int32,
        text:String)
    {
        self.markdown = markdown
        self.address = address
        self.file = file
        self.text = text
    }
}
