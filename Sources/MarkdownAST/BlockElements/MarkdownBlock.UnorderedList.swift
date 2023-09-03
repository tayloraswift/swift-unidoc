import MarkdownABI

extension MarkdownBlock
{
    public final
    class UnorderedList:Container<Item>
    {
        /// Emits a `ul` element.
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            binary[.ul] { super.emit(into: &$0) }
        }
    }
}
