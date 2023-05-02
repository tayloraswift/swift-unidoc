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

        /// Emits a heading element.
        public override
        func emit(into binary:inout MarkdownBinaryEncoder)
        {
            binary[.h(self.level)] { super.emit(into: &$0) }
        }
    }
}
