import Markdown

protocol ParsableAsInlineMarkup
{
    init(from markup:any InlineMarkup)
}
