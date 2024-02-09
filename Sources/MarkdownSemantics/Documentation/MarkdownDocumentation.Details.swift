import MarkdownAST

extension MarkdownDocumentation
{
    @frozen public
    struct Details
    {
        public
        var parameters:Markdown.BlockParameters?
        public
        var returns:Markdown.BlockAside.Returns?
        public
        var `throws`:Markdown.BlockAside.Throws?

        public
        var article:[Markdown.BlockElement]

        public
        init(parameters:Markdown.BlockParameters?,
            returns:Markdown.BlockAside.Returns?,
            throws:Markdown.BlockAside.Throws?,
            article:[Markdown.BlockElement])
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
    @inlinable public
    var isEmpty:Bool
    {
        self.parameters == nil &&
        self.returns == nil &&
        self.throws == nil &&
        self.article.isEmpty
    }
}
extension MarkdownDocumentation.Details
{
    /// Calls ``yield`` once for each block in the structure.
    ///
    /// This coroutine visits the ``parameters``, then the ``returns``, then the ``throws``,
    /// and finally the ``article``.
    @inlinable public
    func visit(_ yield:(Markdown.BlockElement) throws -> ()) rethrows
    {
        try self.parameters.map(yield)
        try self.returns.map(yield)
        try self.throws.map(yield)
        try self.article.forEach(yield)
    }
}
