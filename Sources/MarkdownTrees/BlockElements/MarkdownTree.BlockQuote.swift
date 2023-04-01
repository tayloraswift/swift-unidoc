import MarkdownABI

extension MarkdownTree
{
    public final
    class BlockQuote:BlockContainer<Block>
    {
        public override
        func serialize(into binary:inout MarkdownBinary)
        {
            binary[.blockquote]
            {
                super.serialize(into: &$0)
            }
        }
    }
}
