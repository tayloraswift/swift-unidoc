import HTML
import MarkdownABI

extension HTML.ContentEncoder {
    mutating func emit(
        element: Markdown.Bytecode.Emission,
        with attributes: Markdown.TreeContext.AttributeList
    ) {
        let html: HTML.VoidElement

        switch element {
        case .br:       html = .br
        case .hr:       html = .hr
        case .img:      html = .img
        case .input:    html = .input
        case .wbr:      html = .wbr

        case .area:     html = .area
        case .base:     html = .base
        case .col:      html = .col
        case .link:     html = .link
        case .meta:     html = .meta
        case .param:    html = .param
        case .source:   html = .source
        case .track:    html = .track
        }

        self[html, attributes.encode(to:)]
    }

    mutating func emit(newlines: inout Int) {
        if  newlines == 0 {
            return
        }
        defer {
            newlines = 0
        }

        self[.span] { $0.class = "newline" } = String.init(repeating: "\n", count: newlines)
    }
}
extension HTML.ContentEncoder {
    private mutating func open(
        _ element: HTML.ContainerElement,
        with attributes: Markdown.TreeContext.AttributeList
    ) {
        self.open(element) { attributes.encode(to: &$0) }
    }
    mutating func open(
        context: Markdown.TreeContext,
        with attributes: Markdown.TreeContext.AttributeList
    ) {
        switch context {
        case .anchorable(let element):
            self.open(element, with: attributes)
            self.open(.a) { $0.href = attributes.id?.description }

        case .container(let element):
            self.open(element, with: attributes)

        case .highlight(let highlight):
            self.open(highlight.container, with: attributes)

        case .section(let section):
            self.open(.section, with: attributes)
            self[.h2, { $0.id = section.id }] {
                $0[.a] { $0.href = "#\(section.id)" } = "\(section)"
            }

        case .signage(let signage):
            self.open(.aside, with: attributes)
            self[.h3] = "\(signage)"

        case .snippet:
            self.open(.pre) { $0.class = "snippet" }
            self.open(.code, with: attributes)

            //  Empty newline element to display the first line number.
            self[.span] { $0.class = "newline" }

        //  Ignores all attributes!
        case .transparent:
            return
        }
    }
    mutating func close(context: Markdown.TreeContext) {
        switch context {
        case .anchorable(let element):
            self.close(.a)
            self.close(element)

        case .container(let element):
            self.close(element)

        case .highlight(let highlight):
            self.close(highlight.container)

        case .section:
            self.close(.section)

        case .signage:
            self.close(.aside)

        case .snippet:
            self.close(.code)
            self.close(.pre)

        //  Ignores all attributes!
        case .transparent:
            return
        }
    }
}
