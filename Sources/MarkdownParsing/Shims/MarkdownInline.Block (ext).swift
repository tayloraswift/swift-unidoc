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

        case let link as Link:
            let elements:[MarkdownInline] = link.inlineChildren.map
            {
                MarkdownInline.init(from: $0, in: id)
            }
            guard   let destination:String = link.destination,
                    case [.text(destination)] = elements,
                    let start:String.Index = destination.index(destination.startIndex,
                        offsetBy: 4,
                        limitedBy: destination.endIndex),
                    destination[..<start] == "doc:"
            else
            {
                self = .link(.init(target: link.destination, elements: elements))
                return
            }

            self = .autolink(.init(.doclink(String.init(destination[start...])),
                source: .init(link.range, in: id)))

        case let link as SymbolLink:
            self = .autolink(.init(.codelink(link.destination ?? ""),
                source: .init(link.range, in: id)))

        case let unsupported:
            self = .code(.init(text: "<unsupported markdown node '\(type(of: unsupported))'>"))
        }
    }
}
