extension MarkdownCodeLanguage.PlainText
{
    @frozen public
    enum Highlighter
    {
        case none
    }
}
extension MarkdownCodeLanguage.PlainText.Highlighter:MarkdownCodeHighlighter
{
    /// Writes the text to the binary without any highlighting.
    @inlinable public
    func emit(_ text:String, into binary:inout MarkdownBinaryEncoder)
    {
        binary.write(text: text)
    }
}
