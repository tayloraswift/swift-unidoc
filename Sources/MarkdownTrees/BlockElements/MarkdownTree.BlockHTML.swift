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

        /// Serializes the raw text content of this element.
        public override
        func serialize(into binary:inout MarkdownBinary)
        {
            binary[.none] { $0.write(text: self.text) }
        }
    }
}
