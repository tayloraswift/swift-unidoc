public
protocol MarkdownCodeHighlighter
{
    func emit(_ text:consuming String, into binary:inout MarkdownBinaryEncoder)
}
