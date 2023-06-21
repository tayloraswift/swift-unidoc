import Markdown
import MarkdownTrees
import Sources

extension MarkdownInline.Block:ParsableAsInlineMarkup
{
    init(from markup:any InlineMarkup, in id:Int)
    {
        switch markup
        {
        case is LineBreak:
            self = .text("\n")

        case is SoftBreak:
            self = .text(" ")

        case let span as CustomInline:
            self = .text(span.text)

        case let span as Text:
            self = .text(span.string)

        case let span as InlineHTML:
            self = .html(.init(text: span.rawHTML))

        case let span as InlineCode:
            self = .code(.init(text: span.code))

        case let span as Emphasis:
            self = .container(.init(from: span, in: id, as: .em))

        case let span as Strikethrough:
            self = .container(.init(from: span, in: id, as: .s))

        case let span as Strong:
            self = .container(.init(from: span, in: id, as: .strong))

        case let image as Image:
            self = .image(.init(target: image.source, title: image.title,
                elements: image.inlineChildren.map { MarkdownInline.init(from: $0, in: id) }))

        case let link as SymbolLink:
            self = .autolink(.init(link.destination ?? "",
                code: true, // exclude the backticks from the source range
                source: .init(link.range, in: id, trimming: 2)))

        case let link as Link:
            let elements:[MarkdownInline] = link.inlineChildren.map
            {
                MarkdownInline.init(from: $0, in: id)
            }
            if  let destination:String = link.destination,
                    destination.starts(with: "doc:"),
                    elements.count == 1,
                    elements[0] == .text(destination)
            {
                self = .autolink(.init(destination,
                    code: false, // exclude the angle brackets from the source range
                    source: .init(link.range, in: id, trimming: 1)))
            }
            else
            {
                self = .link(.init(target: link.destination, elements: elements))
            }

        case let unsupported:
            self = .code(.init(text: "<unsupported markdown node '\(type(of: unsupported))'>"))
        }
    }
}
