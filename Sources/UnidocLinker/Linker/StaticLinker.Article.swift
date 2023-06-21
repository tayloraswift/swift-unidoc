import MarkdownSemantics

extension StaticLinker
{
    struct Article
    {
        /// The address of the declaration this article is bound to, or nil if
        /// it is bound to a module.
        let address:Int32?
        let parsed:MarkdownDocumentationSupplement
        let source:MarkdownSource

        init(address:Int32?, parsed:MarkdownDocumentationSupplement, source:MarkdownSource)
        {
            self.address = address
            self.parsed = parsed
            self.source = source
        }
    }
}
