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

        /// Emits nothing.
        public
        func emit(into _:inout MarkdownBinary)
        {
        }
    }
}
