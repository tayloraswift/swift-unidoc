import MarkdownABI

extension MarkdownTree
{
    public final
    class UnorderedList:BlockContainer<BlockItem>
    {
        /// Emits a `ul` element.
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            binary[.ul] { super.emit(into: &$0) }
        }
    }
}
