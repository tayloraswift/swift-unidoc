import MarkdownAST

extension Markdown.InlineSpan: ParsableAsInlineMarkup {
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

        //  These can actually appear in link text; they should be interpreted as
        //  normal code spans.
        case let link as _SymbolLink:
            self = .code(.init(text: link.destination ?? ""))

        case let unsupported:
            self = .code(.init(text: "<unsupported markdown node '\(type(of: unsupported))'>"))
        }
    }
}
