import MarkdownSemantics

struct StandaloneArticle
{
    let markdown:MarkdownDocumentationSupplement
    let address:Int32

    init(markdown:MarkdownDocumentationSupplement, address:Int32)
    {
        self.markdown = markdown
        self.address = address
    }
}
