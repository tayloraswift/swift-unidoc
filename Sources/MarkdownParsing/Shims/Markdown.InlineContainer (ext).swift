import MarkdownABI
import MarkdownAST

extension Markdown.InlineContainer where Element: ParsableAsInlineMarkup {
    init(
        from markup:/* borrowing */ any _InlineContainer,
        in source: borrowing Markdown.Source,
        as type: Markdown.InlineContainerType
    ) {
        self.init(
            type,
            elements: (/* copy */ markup).inlineChildren.map {
                Element.init(from: $0, in: source)
            }
        )
    }
}
