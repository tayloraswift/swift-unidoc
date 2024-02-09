import MarkdownABI

extension MarkdownBlock
{
    public final
    class UnorderedList:Container<Item>
    {
        /// Emits a `ul` element.
        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.ul] { super.emit(into: &$0) }
        }
    }
}
