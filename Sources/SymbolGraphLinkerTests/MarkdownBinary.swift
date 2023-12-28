import HTML
import MarkdownABI
import MarkdownRendering

/// A thin wrapper around some ``MarkdownBytecode``, which conforms to
/// ``HTML.OutputStreamableMarkdown``.
struct MarkdownBinary:HTML.OutputStreamableMarkdown, Equatable, Sendable
{
    let bytecode:MarkdownBytecode

    init(bytecode:MarkdownBytecode)
    {
        self.bytecode = bytecode
    }
}
