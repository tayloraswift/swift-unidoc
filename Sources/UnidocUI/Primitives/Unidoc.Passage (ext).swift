import HTML
import MarkdownABI
import MarkdownRendering

@available(*, unavailable, message: """
    The 'outlines' array is copied from a slice, and indexing it directly without \
    a contextual offset is not correct.
    """)
extension Unidoc.Passage:HTML.OutputStreamableMarkdown
{
    public
    var bytecode:Markdown.Bytecode { [] }
}
