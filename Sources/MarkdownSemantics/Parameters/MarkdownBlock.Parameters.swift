import MarkdownABI
import MarkdownTrees
import Sources

extension MarkdownBlock
{
    public final
    class Parameters:MarkdownBlock
    {
        public
        let discussion:[MarkdownBlock]
        public
        let list:[Parameter]

        @inlinable public
        init(_ discussion:[MarkdownBlock], list:[Parameter] = [])
        {
            self.discussion = discussion
            self.list = list
        }

        /// Recursively calls ``MarkdownTree.outline(by:)`` for each block
        /// in this parameter list’s discussion, and each constituent
        /// parameter.
        public override
        func outline(by register:(String, SourceText<Int>?) throws -> UInt32?) rethrows
        {
            for block:MarkdownBlock in self.discussion
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
                for block:MarkdownBlock in self.discussion
                {
                    block.emit(into: &$0)
                }
                if !self.list.isEmpty
                {
                    $0[.dl]
                    {
                        for parameter:Parameter in self.list
                        {
                            parameter.emit(into: &$0)
                        }
                    }
                }
            }
        }
    }
}
