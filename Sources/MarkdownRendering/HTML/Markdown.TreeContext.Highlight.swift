import HTML

extension Markdown.TreeContext
{
    struct Highlight:Equatable, Hashable, Sendable
    {
        let container:HTML.ContainerElement
        let type:Markdown.SyntaxHighlight

        init(container:HTML.ContainerElement, type:Markdown.SyntaxHighlight)
        {
            self.container = container
            self.type = type
        }
    }
}
