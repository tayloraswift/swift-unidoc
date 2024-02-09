import MarkdownABI

extension MarkdownBlock
{
    public final
    class ThematicBreak:MarkdownBlock
    {
        /// Emits an `hr` element.
        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.hr]
        }
    }
}
