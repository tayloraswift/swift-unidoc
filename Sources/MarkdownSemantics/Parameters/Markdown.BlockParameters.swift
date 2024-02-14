import MarkdownABI
import MarkdownAST
import Sources

extension Markdown
{
    public final
    class BlockParameters:BlockElement
    {
        public
        let discussion:[BlockElement]
        public
        let list:[BlockParameter]

        @inlinable public
        init(_ discussion:[BlockElement], list:[BlockParameter] = [])
        {
            self.discussion = discussion
            self.list = list
        }

        public override
        func emit(into binary:inout BinaryEncoder)
        {
            binary[.parameters]
            {
                for block:BlockElement in self.discussion
                {
                    block.emit(into: &$0)
                }
                if !self.list.isEmpty
                {
                    $0[.dl]
                    {
                        for parameter:BlockParameter in self.list
                        {
                            parameter.emit(into: &$0)
                        }
                    }
                }
            }
        }

        /// Recursively calls ``Markdown.Tree.outline(by:)`` for each block
        /// in this parameter list’s discussion, and each constituent
        /// parameter.
        public override
        func outline(by register:(InlineAutolink) throws -> Int?) rethrows
        {
            //  This element only contains block elements, so we can just forward the closure
            //  to the traversal method.
            try self.traverse { try $0.outline(by: register) }
        }

        public override
        func traverse(_ visit:(BlockElement) throws -> ()) rethrows
        {
            try super.traverse(visit)
            for block:BlockElement in self.discussion
            {
                try block.traverse(visit)
            }
            for parameter:BlockParameter in self.list
            {
                try parameter.traverse(visit)
            }
        }
    }
}
