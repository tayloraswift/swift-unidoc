import MarkdownAST

extension MarkdownTree:MarkdownModel
{
    func visit(_ yield:(MarkdownBlock) throws -> ()) rethrows
    {
        for block:MarkdownBlock in self.blocks
        {
            try yield(block)
        }
    }
}
