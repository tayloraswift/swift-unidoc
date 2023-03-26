import Markdown
import MarkdownTree

extension MarkdownTree.InlineContainer where Element:ParsableAsInlineMarkup
{
    init(from markup:any InlineContainer, as type:MarkdownTree.InlineContainerType)
    {
        self.init(type, elements: markup.inlineChildren.map(Element.init(from:)))
    }
}
