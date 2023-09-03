import MarkdownABI

extension MarkdownBlock
{
    public final
    class Heading:Container<MarkdownInline.Block>
    {
        public
        var level:Int

        @inlinable public
        init(level:Int, elements:[MarkdownInline.Block])
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
extension MarkdownBlock.Heading
{
    /// Clips the heading to the specified maximum level. For example, if `level` is 3, then
    /// this function will demote `h1` and `h2` headings to `h3`, but it will leave `h3` and
    /// `h4` headings alone. This function will never demote headings beyond `h6`.
    @inlinable public
    func clip(to level:Int)
    {
        self.level = min(max(self.level, level), 6)
    }
}
