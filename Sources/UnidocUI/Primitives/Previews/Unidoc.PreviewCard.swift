import HTML
import MarkdownABI

extension Unidoc
{
    protocol PreviewCard<Vertex>:HTML.OutputStreamable
    {
        associatedtype Vertex:PrincipalVertex

        var context:any VertexContext { get }
        var vertex:Vertex { get }
    }
}
extension Unidoc.PreviewCard
{
    var overview:Unidoc.ProseSection?
    {
        self.vertex.overview.map { .init(overview: $0, context: self.context) }
    }
}
