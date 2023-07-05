import MarkdownSemantics

extension StaticLinker
{
    struct Article
    {
        /// The address of the declaration this article is bound to, or nil if
        /// it is bound to a module.
        let scalar:Int32?
        let parsed:MarkdownDocumentationSupplement
        let source:MarkdownSource

        init(scalar:Int32?, parsed:MarkdownDocumentationSupplement, source:MarkdownSource)
        {
            self.scalar = scalar
            self.parsed = parsed
            self.source = source
        }
    }
}
