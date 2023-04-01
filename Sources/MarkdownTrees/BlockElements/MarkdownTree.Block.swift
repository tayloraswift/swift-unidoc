import MarkdownABI

extension MarkdownTree
{
    public
    class Block:MarkdownBinaryConvertibleElement
    {
        @inlinable public
        init()
        {
        }

        /// Serializes nothing.
        public
        func serialize(into _:inout MarkdownBinary)
        {
        }
    }
}
