import MarkdownABI

extension MarkdownBlock
{
    open
    class Aside:Container<MarkdownBlock>
    {
        open class
        var context:Markdown.Bytecode.Context { .blockquote }

        /// Emits the child block elements in this container, wrapped
        /// in this class’s element ``context``.
        public final override
        func emit(into binary:inout Markdown.BinaryEncoder)
        {
            binary[Self.context]
            {
                super.emit(into: &$0)
            }
        }
    }
}
