import MarkdownAST
import Sources

extension Markdown.InlineElement:ParsableAsInlineMarkup
{
    init(from markup:/* borrowing */ any _InlineMarkup, in source:borrowing Markdown.Source)
    {
        switch /* copy */ markup
        {
        case is _LineBreak:
            self = .text("\n")

        case is _SoftBreak:
            self = .text(" ")

        case let span as _CustomInline:
            self = .text(span.text)

        case let span as _Text:
            self = .text(span.string)

        case let span as _InlineHTML:
            self = .html(.init(text: span.rawHTML))

        case let span as _InlineCode:
            self = .code(.init(text: span.code))

        case let span as _Emphasis:
            self = .container(.init(from: span, in: source, as: .em))

        case let span as _Strikethrough:
            self = .container(.init(from: span, in: source, as: .s))

        case let span as _Strong:
            self = .container(.init(from: span, in: source, as: .strong))

        case let image as _Image:
            self = .image(.init(target: image.source,
                title: image.title,
                elements: image.inlineChildren.map
                {
                    Markdown.InlineSpan.init(from: $0, in: source)
                }))

        case let link as _SymbolLink:
            // exclude the backticks from the source range
            self = .autolink(.init(
                source: .init(trimming: 2, from: link.range, in: copy source),
                text: link.destination ?? "",
                code: true))

        case let link as _Link:
            let elements:[Markdown.InlineSpan] = link.inlineChildren.map
            {
                Markdown.InlineSpan.init(from: $0, in: source)
            }
            if  let destination:String = link.destination,
                let colon:String.Index = destination.firstIndex(of: ":"),
                    destination[..<colon] == "doc",
                    elements.count == 1,
                    elements[0] == .text(destination)
            {
                // exclude the angle brackets from the source range
                self = .autolink(.init(
                    source: .init(trimming: 1, from: link.range, in: copy source),
                    text: String.init(destination[destination.index(after: colon)...]),
                    code: false))
            }
            else
            {
                self = .link(.init(
                    source: .init(trimming: 1, from: link.range, in: copy source),
                    target: link.destination,
                    elements: elements))
            }

        case let unsupported:
            self = .code(.init(text: "<unsupported markdown node '\(type(of: unsupported))'>"))
        }
    }
}
