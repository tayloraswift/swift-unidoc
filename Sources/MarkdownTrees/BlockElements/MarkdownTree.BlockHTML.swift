import MarkdownABI

extension MarkdownTree
{
    public final
    class BlockHTML:Block
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
        func emit(into binary:inout MarkdownBinary)
        {
            binary[.transparent] = self.text
        }
    }
}
