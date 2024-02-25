import MarkdownABI
import MarkdownAST

extension Markdown
{
    public final
    class BlockTerm:BlockContainer<BlockElement>
    {
        public
        let name:String
        public
        let code:Bool

        @inlinable public
        init(elements:[BlockElement], name:String, code:Bool)
        {
            self.name = name
            self.code = code
            super.init(elements)
        }

        public override
        func emit(into binary:inout BinaryEncoder)
        {
            binary[.dt, { $0[.id] = "st:\(self.name)" }]
            {
                $0[self.code ? .code : .em] = self.name
            }
            binary[.dd]
            {
                super.emit(into: &$0)
            }
        }
    }
}
