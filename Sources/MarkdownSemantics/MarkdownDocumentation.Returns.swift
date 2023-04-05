import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    @frozen public
    struct Returns
    {
        public
        var discussion:[MarkdownTree.Block]

        @inlinable public
        init?(_ discussion:[MarkdownTree.Block] = [])
        {
            if  discussion.isEmpty
            {
                return nil
            }
            self.discussion = discussion
        }
    }
}
extension MarkdownDocumentation.Returns
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.returns]
        {
            for block:MarkdownTree.Block in self.discussion
            {
                block.emit(into: &$0)
            }
        }
    }
}
