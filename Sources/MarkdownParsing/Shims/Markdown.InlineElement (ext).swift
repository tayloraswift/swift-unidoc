import MarkdownAST
import Sources

extension Markdown.InlineElement: ParsableAsInlineMarkup {
    init(from markup:/* borrowing */ any _InlineMarkup, in source: borrowing Markdown.Source) {
        switch /* copy */ markup {
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
            self = .image(
                .init(
                    elements: image.inlineChildren.map {
                        Markdown.InlineSpan.init(from: $0, in: source)
                    },
                    target: image.source.map {
                        .inline(
                            .init(
                                source: .init(from: image.range, in: copy source),
                                string: $0
                            )
                        )
                    },
                    title: image.title
                )
            )

        case let link as _SymbolLink:
            // exclude the backticks from the source range
            let link: Markdown.InlineAutolink = .code(
                link: link.destination ?? "",
                at: .init(trimming: 2, from: link.range, in: copy source)
            )

            self = .autolink(link)

        case let link as _Link:
            let elements: [Markdown.InlineSpan] = link.inlineChildren.map {
                Markdown.InlineSpan.init(from: $0, in: source)
            }
            if  let destination: String = link.destination,
                elements.count == 1,
                elements[0] == .text(destination) {
                // exclude the angle brackets from the source range
                let link: Markdown.InlineAutolink = .doc(
                    link: destination,
                    at: .init(trimming: 1, from: link.range, in: copy source)
                )

                self = .autolink(link)
            } else {
                let link: Markdown.InlineHyperlink = .init(
                    source: .init(trimming: 1, from: link.range, in: copy source),
                    target: link.destination,
                    elements: elements
                )

                self = .link(link)
            }

        case let unsupported:
            self = .code(.init(text: "<unsupported markdown node '\(type(of: unsupported))'>"))
        }
    }
}
