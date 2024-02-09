import MarkdownABI

extension Markdown.CodeLanguageType where Self == Markdown.SwiftLanguage
{
    @inlinable public static
    var swift:Self { .init() }
}
