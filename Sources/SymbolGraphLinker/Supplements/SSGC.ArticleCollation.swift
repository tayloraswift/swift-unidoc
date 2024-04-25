import MarkdownSemantics

extension SSGC
{
    /// An article collation is constructed by combining one or more
    /// ``Markdown.SemanticDocument``s.
    struct ArticleCollation
    {
        let combined:Markdown.SemanticDocument
        let scope:[String]
        let file:Int32?

        init(combined:Markdown.SemanticDocument, scope:[String], file:Int32?)
        {
            self.combined = combined
            self.scope = scope
            self.file = file
        }
    }
}
