import MarkdownABI
import MarkdownAST

extension Markdown
{
    public final
    class BlockTerms:BlockContainer<BlockTerm>
    {
        public override
        func emit(into binary:inout BinaryEncoder)
        {
            binary[.dl]
            {
                super.emit(into: &$0)
            }
        }
    }
}
