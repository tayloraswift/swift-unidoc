import Markdown
import MarkdownTrees

extension MarkdownInline.Container where Element:ParsableAsInlineMarkup
{
    init(from markup:any InlineContainer, as type:MarkdownInline.ContainerType)
    {
        self.init(type, elements: markup.inlineChildren.map(Element.init(from:)))
    }
}
