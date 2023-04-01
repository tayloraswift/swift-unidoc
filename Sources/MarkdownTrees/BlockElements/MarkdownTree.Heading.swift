import MarkdownABI

extension MarkdownTree
{
    public final
    class Heading:BlockContainer<InlineBlock>
    {
        public
        var level:Int

        @inlinable public
        init(level:Int, elements:[InlineBlock])
        {
            self.level = level
            super.init(elements)
        }
    }
}
