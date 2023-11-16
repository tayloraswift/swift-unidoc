import MarkdownABI
import MarkdownRendering

/// A thin wrapper around some ``MarkdownBytecode``, which conforms to
/// ``HyperTextRenderableMarkdown``.
struct MarkdownBinary:HyperTextRenderableMarkdown, Equatable, Sendable
{
    let bytecode:MarkdownBytecode

    init(bytecode:MarkdownBytecode)
    {
        self.bytecode = bytecode
    }
}
