extension Markdown.PlainText
{
    @frozen public
    enum Highlighter
    {
        case none
    }
}
extension Markdown.PlainText.Highlighter:Markdown.CodeHighlighter
{
    /// Writes the text to the binary without any highlighting.
    @inlinable public
    func emit(_ text:String, into binary:inout Markdown.BinaryEncoder)
    {
        binary += text
    }
}
