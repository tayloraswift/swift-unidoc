import MarkdownABI

extension MarkdownCodeLanguage.Swift
{
    @frozen public
    struct Highlighter
    {
        @inlinable public
        init()
        {
        }
    }
}
extension MarkdownCodeLanguage.Swift.Highlighter:MarkdownCodeHighlighter
{
    @inlinable public
    func emit(_ text:String, into binary:inout MarkdownBinaryEncoder)
    {
        //  TODO: highlight code
        binary.write(text: text)
    }
}
