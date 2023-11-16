import Markdown
import MarkdownAST

protocol ParsableAsInlineMarkup
{
    init(from markup:borrowing any InlineMarkup, in source:borrowing MarkdownSource)
}
