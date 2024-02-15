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
    /// Calls ``visit`` recursively for all blocks in the structure.
    ///
    /// This coroutine visits the ``parameters``, then the ``returns``, then the ``throws``,
    /// and finally the ``article``.
    @inlinable public
    func traverse(with visit:(Markdown.BlockElement) throws -> ()) rethrows
    {
        try self.parameters?.traverse(with: visit)
        try self.returns?.traverse(with: visit)
        try self.throws?.traverse(with: visit)

        for block:Markdown.BlockElement in self.article
        {
            try block.traverse(with: visit)
        }
    }

    @inlinable public
    func emit(into binary:inout Markdown.BinaryEncoder)
    {
        self.parameters?.emit(into: &binary)
        self.returns?.emit(into: &binary)
        self.throws?.emit(into: &binary)

        for block:Markdown.BlockElement in self.article
        {
            block.emit(into: &binary)
        }
    }
}
