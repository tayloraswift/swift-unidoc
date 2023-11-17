import MarkdownAST

@frozen public
struct MarkdownDocumentation
{
    public
    var metadata:Metadata
    public
    var overview:MarkdownBlock.Paragraph?
    public
    var details:Details
    public
    var topics:[Topic]

    @inlinable public
    init(
        metadata:Metadata,
        overview:MarkdownBlock.Paragraph?,
        details:Details,
        topics:[Topic])
    {
        self.metadata = metadata
        self.overview = overview
        self.details = details
        self.topics = topics
    }
}
extension MarkdownDocumentation
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
        if  let first:MarkdownBlock.Paragraph = body.overview
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
    func merged(appending body:MarkdownDocumentation) -> MarkdownDocumentation
    {
        self.merge(appending: body)
        return self
    }
}
