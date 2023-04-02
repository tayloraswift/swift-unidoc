import MarkdownABI

extension MarkdownTree
{
    public final
    class OrderedList:BlockContainer<BlockItem>
    {
        /// Emits an `ol` element.
        public override
        func emit(into binary:inout MarkdownBinary)
        {
            binary[.ol] { super.emit(into: &$0) }
        }
    }
}
