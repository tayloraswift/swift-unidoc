public
protocol MarkdownCodeHighlighter
{
    func emit(_ text:String, into binary:inout MarkdownBinaryEncoder)
}
