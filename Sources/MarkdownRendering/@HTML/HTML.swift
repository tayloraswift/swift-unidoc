import HTMLRendering

extension HTML
{
    mutating
    func emit(element:MarkdownBytecode.Emission, with attributes:MarkdownAttributeContext)
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
}
extension HTML
{
    private mutating
    func open(_ element:ContainerElement, with attributes:MarkdownAttributeContext)
    {
        self.open(element) { attributes.encode(to: &$0) }
    }
    mutating
    func open(context:MarkdownElementContext, with attributes:MarkdownAttributeContext)
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
        
        //  Ignores all attributes!
        case .transparent:
            return
        }
    }
}
