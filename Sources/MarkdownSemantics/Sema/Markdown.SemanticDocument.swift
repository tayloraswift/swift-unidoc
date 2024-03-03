import MarkdownAST

extension Markdown
{
    @frozen public
    struct SemanticDocument
    {
        public
        var metadata:SemanticMetadata
        public
        var overview:BlockParagraph?
        public
        var details:SemanticSections
        public
        var topics:[Markdown.BlockTopic]

        @inlinable public
        init(
            metadata:SemanticMetadata,
            overview:BlockParagraph?,
            details:SemanticSections,
            topics:[Markdown.BlockTopic])
        {
            self.metadata = metadata
            self.overview = overview
            self.details = details
            self.topics = topics
        }
    }
}
extension Markdown.SemanticDocument
{
    /// Merges the given documentation into this documentation.
    ///
    /// If this documentation has no Parameters, Returns, or Throws sections,
    /// then this function adds them from the new documentation, if it has them.
    /// If the new documentation has such sections, but they are already present
    /// in this documentation, then the new documentation’s sections are ignored.
    ///
    /// If the new documentation has an Overview section, then this function adds
    /// it to this documentation Details section as a regular body paragraph, even
    /// if this documentation lacks an Overview section of its own.
    public mutating
    func merge(appending body:Self)
    {
        if  let first:Markdown.BlockParagraph = body.overview
        {
            self.details.article.append(first)
        }
        if  case nil = self.details.parameters
        {
            self.details.parameters = body.details.parameters
        }
        if  case nil = self.details.returns
        {
            self.details.returns = body.details.returns
        }
        if  case nil = self.details.throws
        {
            self.details.throws = body.details.throws
        }

        self.details.article += body.details.article
        self.topics += body.topics
    }

    @_documentation(metadata: "see: merge(appending:)")
    public consuming
    func merged(appending body:Markdown.SemanticDocument) -> Markdown.SemanticDocument
    {
        self.merge(appending: body)
        return self
    }
}
