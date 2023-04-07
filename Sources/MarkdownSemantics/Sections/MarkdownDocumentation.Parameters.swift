import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    @frozen public
    struct Parameters
    {
        public
        let discussion:[MarkdownTree.Block]
        public
        let list:[Parameter]

        @inlinable public
        init?(discussion:[MarkdownTree.Block], list:[Parameter])
        {
            if  discussion.isEmpty, list.isEmpty
            {
                return nil
            }
            self.discussion = discussion
            self.list = list
        }
    }
}
extension MarkdownDocumentation.Parameters
{
    public
    func emit(into binary:inout MarkdownBinary)
    {
        binary[.parameters]
        {
            for block:MarkdownTree.Block in self.discussion
            {
                block.emit(into: &$0)
            }
            if !self.list.isEmpty
            {
                $0[.dl]
                {
                    for parameter:MarkdownDocumentation.Parameter in self.list
                    {
                        parameter.emit(into: &$0)
                    }
                }
            }
        }
    }
}
