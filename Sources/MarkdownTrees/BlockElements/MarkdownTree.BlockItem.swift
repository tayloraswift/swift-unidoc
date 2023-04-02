import MarkdownABI

extension MarkdownTree
{
    public final
    class BlockItem:BlockContainer<Block>
    {
        public
        var checkbox:Checkbox?

        @inlinable public
        init(checkbox:Checkbox? = nil, elements:[Block])
        {
            self.checkbox = checkbox
            super.init(elements)
        }

        /// Emits an `li` element.
        public override
        func emit(into binary:inout MarkdownBinary)
        {
            binary[.li]
            {
                self.checkbox?.emit(into: &$0)
                super.emit(into: &$0)
            }
        }
    }
}
