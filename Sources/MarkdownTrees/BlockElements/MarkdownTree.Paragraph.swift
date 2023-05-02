import MarkdownABI

extension MarkdownTree
{
    public final
    class Paragraph:BlockContainer<InlineBlock>
    {
        /// Emits a `p` element.
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            binary[.p] { super.emit(into: &$0) }
        }
    }
}
