import MarkdownABI

extension MarkdownTree
{
    public final
    class ThematicBreak:Block
    {
        /// Emits an `hr` element.
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            binary[.hr]
        }
    }
}
