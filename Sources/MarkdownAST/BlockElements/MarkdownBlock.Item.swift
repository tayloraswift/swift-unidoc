import MarkdownABI

extension MarkdownBlock
{
    public final
    class Item:Container<MarkdownBlock>
    {
        public
        var checkbox:Checkbox?

        @inlinable public
        init(checkbox:Checkbox? = nil, elements:[MarkdownBlock])
        {
            self.checkbox = checkbox
            super.init(elements)
        }

        /// Emits an `li` element.
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            binary[.li]
            {
                self.checkbox?.emit(into: &$0)
                super.emit(into: &$0)
            }
        }
    }
}
