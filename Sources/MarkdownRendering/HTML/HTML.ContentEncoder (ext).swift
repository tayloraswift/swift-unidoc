import HTML
import MarkdownABI

extension HTML.ContentEncoder
{
    mutating
    func emit(element:MarkdownBytecode.Emission,
        with attributes:MarkdownElementContext.AttributeContext)
    {
        let html:HTML.VoidElement

        switch element
        {
        case .br:       html = .br
        case .hr:       html = .hr
        case .img:      html = .img
        case .input:    html = .input
        case .wbr:      html = .wbr
        }

        self[html, attributes.encode(to:)]
    }

    mutating
    func emit(newlines:inout Int)
    {
        if  newlines == 0
        {
            return
        }
        defer
        {
            newlines = 0
        }

        self[.span] { $0.class = "newline" } = String.init(repeating: "\n", count: newlines)
    }
}
extension HTML.ContentEncoder
{
    private mutating
    func open(_ element:HTML.ContainerElement,
        with attributes:MarkdownElementContext.AttributeContext)
    {
        self.open(element) { attributes.encode(to: &$0) }
    }
    mutating
    func open(context:MarkdownElementContext,
        with attributes:MarkdownElementContext.AttributeContext)
    {
        switch context
        {
        case .container(let element):
            self.open(element, with: attributes)

        case .highlight(let highlight):
            self.open(highlight.container, with: attributes)

        case .section(let section):
            self.open(.section, with: attributes)
            self[.h2] = section.description

        case .signage(let signage):
            self.open(.aside, with: attributes)
            self[.h3] = signage.description

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
    mutating
    func close(context:MarkdownElementContext)
    {
        switch context
        {
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
