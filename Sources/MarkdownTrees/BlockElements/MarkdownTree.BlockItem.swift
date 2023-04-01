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

        public override
        func serialize(into binary:inout MarkdownBinary)
        {
            binary[.li]
            {
                self.checkbox?.serialize(into: &$0)
                super.serialize(into: &$0)
            }
        }
    }
}
