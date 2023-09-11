import HTML

extension MarkdownElementContext
{
    struct Highlight:Equatable, Hashable, Sendable
    {
        let container:HTML.ContainerElement
        let type:MarkdownSyntaxHighlight

        init(container:HTML.ContainerElement, type:MarkdownSyntaxHighlight)
        {
            self.container = container
            self.type = type
        }
    }
}
