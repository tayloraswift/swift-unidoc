import MarkdownABI

extension MarkdownBlock
{
    public final
    class Paragraph:Container<MarkdownInline.Block>
    {
        /// Emits a `p` element.
        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.p] { super.emit(into: &$0) }
        }
    }
}
