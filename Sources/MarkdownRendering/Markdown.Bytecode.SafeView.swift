import HTML
import MarkdownABI

extension Markdown.Bytecode {
    /// Renders the wrapped bytecode without inlining any references.
    @frozen public struct SafeView: Equatable, Sendable {
        public let bytecode: Markdown.Bytecode

        @inlinable internal init(_ bytecode: Markdown.Bytecode) {
            self.bytecode = bytecode
        }
    }
}
extension Markdown.Bytecode.SafeView: HTML.OutputStreamableMarkdown {
}
extension Markdown.Bytecode.SafeView: TextOutputStreamableMarkdown {
}
