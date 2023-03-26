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
    }
}
