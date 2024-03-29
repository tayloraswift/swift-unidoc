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

        public override
        func traverse(with visit:(BlockElement) throws -> ()) rethrows
        {
            try super.traverse(with: visit)
            for block:BlockElement in self.discussion
            {
                try block.traverse(with: visit)
            }
            for parameter:BlockParameter in self.list
            {
                try parameter.traverse(with: visit)
            }
        }
    }
}
