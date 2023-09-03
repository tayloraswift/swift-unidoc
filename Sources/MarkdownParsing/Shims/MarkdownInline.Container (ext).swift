import Markdown
import MarkdownAST

extension MarkdownInline.Container where Element:ParsableAsInlineMarkup
{
    init(from markup:any InlineContainer, in id:Int, as type:MarkdownInline.ContainerType)
    {
        self.init(type, elements: markup.inlineChildren.map { Element.init(from: $0, in: id) })
    }
}
