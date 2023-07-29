import MarkdownABI

extension MarkdownBytecode
{
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
