import HTML
import MarkdownABI
import MarkdownRendering

/// A thin wrapper around some ``Markdown.Bytecode``, which conforms to
/// ``HTML.OutputStreamableMarkdown``.
struct MarkdownBinary: HTML.OutputStreamableMarkdown, Equatable, Sendable {
    let bytecode: Markdown.Bytecode

    init(bytecode: Markdown.Bytecode) {
        self.bytecode = bytecode
    }
}
