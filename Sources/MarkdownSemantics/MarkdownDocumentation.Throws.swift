import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    @frozen public
    struct Throws
    {
        public
        let discussion:[MarkdownTree.Block]

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
extension MarkdownDocumentation.Throws
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.throws]
        {
            for block:MarkdownTree.Block in self.discussion
            {
                block.emit(into: &$0)
            }
        }
    }
}
