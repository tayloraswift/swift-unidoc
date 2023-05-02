import MarkdownTrees

extension MarkdownDocumentation
{
    @frozen public
    struct Details
    {
        public
        var parameters:Parameters?
        public
        var returns:Returns?
        public
        var `throws`:Throws?

        public
        var article:[MarkdownTree.Block]

        public
        init(parameters:Parameters?, returns:Returns?, throws:Throws?,
            article:[MarkdownTree.Block])
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
    public
    func visit(_ yield:(MarkdownTree.Block) throws -> ()) rethrows
    {
        try self.parameters.map(yield)
        try self.returns.map(yield)
        try self.throws.map(yield)
        try self.article.forEach(yield)
    }
}
