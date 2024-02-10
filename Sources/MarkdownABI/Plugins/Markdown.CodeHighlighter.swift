extension Markdown
{
    public
    typealias CodeHighlighter = _MarkdownCodeHighlighter
}
/// The name of this protocol is ``Markdown.CodeHighlighter``.
public
protocol _MarkdownCodeHighlighter
{
    func emit(_ text:consuming String, into binary:inout Markdown.BinaryEncoder)
}
