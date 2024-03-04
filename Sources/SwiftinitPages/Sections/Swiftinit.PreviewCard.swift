import HTML
import MarkdownABI

extension Swiftinit
{
    typealias PreviewCard = _SwiftinitPreviewCard
}

protocol _SwiftinitPreviewCard:HTML.OutputStreamable
{
    var context:any Swiftinit.VertexPageContext { get }
    var passage:Unidoc.Passage? { get }
}
extension Swiftinit.PreviewCard
{
    var overview:Markdown.ProseSection?
    {
        self.passage.map { .init(self.context, overview: $0) }
    }
}
