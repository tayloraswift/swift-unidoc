import Markdown
import MarkdownAST
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
            // exclude the backticks from the source range
            self = .autolink(.init(
                source: .init(file: id, trimming: 2, from: link.range),
                text: link.destination ?? "",
                code: true))

        case let link as Link:
            let elements:[MarkdownInline] = link.inlineChildren.map
            {
                MarkdownInline.init(from: $0, in: id)
            }
            if  let destination:String = link.destination,
                let colon:String.Index = destination.firstIndex(of: ":"),
                    destination[..<colon] == "doc",
                    elements.count == 1,
                    elements[0] == .text(destination)
            {
                // exclude the angle brackets from the source range
                self = .autolink(.init(
                    source: .init(file: id, trimming: 1, from: link.range),
                    text: String.init(destination[destination.index(after: colon)...]),
                    code: false))
            }
            else
            {
                self = .link(.init(
                    source: .init(file: id, trimming: 1, from: link.range),
                    target: link.destination,
                    elements: elements))
            }

        case let unsupported:
            self = .code(.init(text: "<unsupported markdown node '\(type(of: unsupported))'>"))
        }
    }
}
