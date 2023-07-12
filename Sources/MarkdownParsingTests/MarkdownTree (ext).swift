import MarkdownTrees

extension MarkdownTree:MarkdownModel
{
    public
    func visit(_ yield:(MarkdownBlock) throws -> ()) rethrows
    {
        for block:MarkdownBlock in self.blocks
        {
            try yield(block)
        }
    }
}
