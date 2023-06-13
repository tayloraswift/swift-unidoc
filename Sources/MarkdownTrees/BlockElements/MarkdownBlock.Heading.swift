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
    /// Demotes the heading by the specified number of levels, down to a minimum
    /// level of 6.
    public
    func demote(by levels:Int = 1)
    {
        self.level = min(6, self.level + levels)
    }
}
