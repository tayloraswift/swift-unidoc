extension Markdown {
    public protocol CodeLanguageType {
        associatedtype Highlighter: Markdown.CodeHighlighter

        var name: String { get }
        var highlighter: Highlighter { get }
    }
}
extension Markdown.CodeLanguageType where Self == Markdown.CodeLanguage {
    @inlinable public static func unsupported(_ name: String) -> Self {
        .init(name)
    }
}
