import MarkdownABI

extension Markdown
{
    public final
    class BlockParagraph:BlockContainer<Markdown.InlineElement>
    {
        /// Emits a `p` element.
        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.p] { super.emit(into: &$0) }
        }
    }
}
