import MarkdownTrees

extension MarkdownDocumentation
{
    @frozen public
    struct Details
    {
        public
        var parameters:MarkdownBlock.Parameters?
        public
        var returns:MarkdownBlock.Aside.Returns?
        public
        var `throws`:MarkdownBlock.Aside.Throws?

        public
        var article:[MarkdownBlock]

        public
        init(parameters:MarkdownBlock.Parameters?,
            returns:MarkdownBlock.Aside.Returns?,
            throws:MarkdownBlock.Aside.Throws?,
            article:[MarkdownBlock])
        {
            self.parameters = parameters
            self.returns = returns
            self.throws = `throws`
            self.article = article
        }
    }
}
extension MarkdownDocumentation.Details
{
    /// Calls ``yield`` once for each block in the structure.
    public
    func visit(_ yield:(MarkdownBlock) throws -> ()) rethrows
    {
        try self.parameters.map(yield)
        try self.returns.map(yield)
        try self.throws.map(yield)
        try self.article.forEach(yield)
    }
}
