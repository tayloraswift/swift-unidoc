import HTML
import MarkdownABI

extension Unidoc
{
    protocol PreviewCard:HTML.OutputStreamable
    {
        var context:any VertexContext { get }
        var passage:Passage? { get }
    }
}
extension Unidoc.PreviewCard
{
    var overview:Markdown.ProseSection?
    {
        self.passage.map { .init(self.context, overview: $0) }
    }
}
