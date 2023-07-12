@frozen public
struct MarkdownCodeLanguage
{
    public
    let name:String

    @inlinable internal
    init(_ name:String)
    {
        self.name = name
    }
}
extension MarkdownCodeLanguage:MarkdownCodeLanguageType
{
    @inlinable public
    var highlighter:PlainText.Highlighter { .none }
}
