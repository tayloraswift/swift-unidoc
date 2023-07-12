import MarkdownABI

extension MarkdownCodeLanguage
{
    @frozen public
    enum Swift:MarkdownCodeLanguageType
    {
        case swift

        @inlinable public
        var name:String { "swift" }

        @inlinable public
        var highlighter:Highlighter { .init() }
    }
}
