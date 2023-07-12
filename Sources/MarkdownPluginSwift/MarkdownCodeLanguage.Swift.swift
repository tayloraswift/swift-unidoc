import MarkdownABI

extension MarkdownCodeLanguage
{
    @frozen public
    struct Swift
    {
        @inlinable internal
        init()
        {
        }
    }
}
extension MarkdownCodeLanguage.Swift:MarkdownCodeLanguageType
{
    @inlinable public
    var name:String { "swift" }

    @inlinable public
    var highlighter:Highlighter { .init() }
}
