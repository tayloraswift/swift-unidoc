extension Markdown
{
    @frozen public
    struct CodeLanguage
    {
        public
        let name:String

        @inlinable internal
        init(_ name:String)
        {
            self.name = name
        }
    }
}
extension Markdown.CodeLanguage:Markdown.CodeLanguageType
{
    @inlinable public
    var highlighter:Markdown.PlainText.Highlighter { .none }
}
