import MarkdownABI

extension MarkdownBlock
{
    public final
    class OrderedList:Container<Item>
    {
        /// Emits an `ol` element.
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            binary[.ol] { super.emit(into: &$0) }
        }
    }
}
