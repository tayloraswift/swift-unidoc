import MarkdownABI

extension MarkdownTree
{
    public final
    class BlockQuote:BlockContainer<Block>
    {
        /// Emits a `blockquote` element.
        public override
        func emit(into binary:inout MarkdownBinary)
        {
            binary[.blockquote]
            {
                super.emit(into: &$0)
            }
        }
    }
}
