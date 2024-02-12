import MarkdownAST

extension Markdown
{
    @frozen public
    struct SemanticSections
    {
        public
        var parameters:BlockParameters?
        public
        var returns:BlockAside.Returns?
        public
        var `throws`:BlockAside.Throws?

        public
        var article:[BlockElement]

        public
        init(parameters:BlockParameters?,
            returns:BlockAside.Returns?,
            throws:BlockAside.Throws?,
            article:[BlockElement])
        {
            self.parameters = parameters
            self.returns = returns
            self.throws = `throws`
            self.article = article
        }
    }
}
extension Markdown.SemanticSections
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
extension Markdown.SemanticSections
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
