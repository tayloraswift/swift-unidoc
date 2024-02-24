import MarkdownABI
import MarkdownAST

extension Markdown
{
    public final
    class BlockParameter:BlockContainer<BlockElement>
    {
        public
        let name:String

        @inlinable public
        init(elements:[BlockElement], name:String)
        {
            self.name = name
            super.init(elements)
        }

        public override
        func emit(into binary:inout BinaryEncoder)
        {
            binary[.dt] { $0[.id] = "sp:\(self.name)" } = self.name
            binary[.dd]
            {
                super.emit(into: &$0)
            }
        }
    }
}
