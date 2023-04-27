import MarkdownABI

extension MarkdownTree
{
    open
    class BlockAside:BlockContainer<Block>
    {
        open class
        var context:MarkdownBytecode.Context { .blockquote }

        /// Emits the child block elements in this container, wrapped
        /// in this class’s element ``context``.
        public final override
        func emit(into binary:inout MarkdownBinary)
        {
            binary[Self.context]
            {
                super.emit(into: &$0)
            }
        }
    }
}
