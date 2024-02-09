import MarkdownAST

protocol ParsableAsInlineMarkup
{
    init(from markup:borrowing any _InlineMarkup, in source:borrowing MarkdownSource)
}
