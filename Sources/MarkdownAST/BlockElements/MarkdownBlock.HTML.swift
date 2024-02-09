import MarkdownABI

extension MarkdownBlock
{
    public final
    class HTML:MarkdownBlock
    {
        public
        var text:String

        @inlinable public
        init(text:String)
        {
            self.text = text
        }

        /// Emits the raw text content of this element in a transparent instruction context.
        public override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[.transparent] = self.text
        }
    }
}
