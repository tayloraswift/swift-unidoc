import Markdown
import MarkdownAST

extension MarkdownInline.Container where Element:ParsableAsInlineMarkup
{
    init(from markup:borrowing any InlineContainer,
        in source:borrowing MarkdownSource,
        as type:MarkdownInline.ContainerType)
    {
        self.init(type,
            elements: (copy markup).inlineChildren.map { Element.init(from: $0, in: source) })
    }
}
