import MarkdownABI
import MarkdownTrees

extension MarkdownDocumentation
{
    public final
    class Parameters:MarkdownTree.Block
    {
        public
        let discussion:[MarkdownTree.Block]
        public
        let list:[MarkdownDocumentation.Parameter]

        @inlinable public
        init(_ discussion:[MarkdownTree.Block], list:[MarkdownDocumentation.Parameter] = [])
        {
            self.discussion = discussion
            self.list = list
        }

        /// Recursively calls ``MarkdownTree.outline(by:)`` for each block
        /// in this parameter list’s discussion, and each constituent
        /// parameter.
        public override
        func outline(by register:(String) throws -> UInt32?) rethrows
        {
            for block:MarkdownTree.Block in self.discussion
            {
                try block.outline(by: register)
            }
            for parameter:Parameter in self.list
            {
                try parameter.outline(by: register)
            }
        }
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
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
}
