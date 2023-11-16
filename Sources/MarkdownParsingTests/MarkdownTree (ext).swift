import MarkdownAST

extension MarkdownTree
{
    func visit(_ yield:(MarkdownBlock) throws -> ()) rethrows
    {
        for block:MarkdownBlock in self.blocks
        {
            try yield(block)
        }
    }
}
