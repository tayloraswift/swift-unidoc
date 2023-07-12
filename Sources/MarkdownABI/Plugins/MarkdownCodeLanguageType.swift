public
protocol MarkdownCodeLanguageType
{
    associatedtype Highlighter:MarkdownCodeHighlighter

    var name:String { get }
    var highlighter:Highlighter { get }
}
extension MarkdownCodeLanguageType where Self == MarkdownCodeLanguage
{
    @inlinable public static
    func unsupported(_ name:String) -> Self
    {
        .init(name)
    }
}
