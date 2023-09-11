import MarkdownABI

extension MarkdownBytecode
{
    /// Renders the wrapped bytecode without inlining any references.
    @frozen public
    struct SafeView:Equatable, Sendable
    {
        public
        let bytecode:MarkdownBytecode

        @inlinable internal
        init(_ bytecode:MarkdownBytecode)
        {
            self.bytecode = bytecode
        }
    }
}
extension MarkdownBytecode.SafeView:HyperTextRenderableMarkdown
{
}
extension MarkdownBytecode.SafeView:PlainTextRenderableMarkdown
{
}
