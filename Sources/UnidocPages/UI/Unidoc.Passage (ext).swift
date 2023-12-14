import MarkdownABI
import MarkdownRendering
import UnidocRecords

@available(*, unavailable, message: """
    The 'outlines' array is copied from a slice, and indexing it directly without \
    a contextual offset is not correct.
    """)
extension Unidoc.Passage:HyperTextRenderableMarkdown
{
    public
    var bytecode:MarkdownBytecode { [] }
}
