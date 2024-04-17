import HTML
import MarkdownABI

extension Swiftinit
{
    protocol PreviewCard:HTML.OutputStreamable
    {
        var context:any Unidoc.VertexContext { get }
        var passage:Unidoc.Passage? { get }
    }
}
extension Swiftinit.PreviewCard
{
    var overview:Markdown.ProseSection?
    {
        self.passage.map { .init(self.context, overview: $0) }
    }
}
