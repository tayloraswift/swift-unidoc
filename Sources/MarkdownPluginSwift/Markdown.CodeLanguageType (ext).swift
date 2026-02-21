import MarkdownABI

extension Markdown.CodeLanguageType where Self == Markdown.SwiftLanguage {
    @inlinable public static var swift: Self { .swift(index: nil) }

    @inlinable public static func swift(
        index: (any Markdown.SwiftLanguage.IndexStore)?
    ) -> Self {
        .init(index: index)
    }
}
