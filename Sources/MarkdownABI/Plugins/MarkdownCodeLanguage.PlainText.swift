extension MarkdownCodeLanguage
{
    /// An uninhabited type that markdown parsers can substitute for ``MarkdownBlock.Code``’s
    /// type parameter when emitting code blocks without a code language.
    @frozen public
    enum PlainText
    {
    }
}
extension MarkdownCodeLanguage.PlainText:MarkdownCodeLanguageType
{
    /// Uncallable.
    @inlinable public
    var name:String { (nil as Self?)! }
    /// Uncallable.
    @inlinable public
    var highlighter:Highlighter { (nil as Self?)! }
}
