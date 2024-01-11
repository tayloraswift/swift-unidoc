import HTML
import UnidocRecords

extension Swiftinit
{
    struct ArticleCard
    {
        let context:any Swiftinit.VertexPageContext

        let vertex:Unidoc.ArticleVertex
        let target:String

        init(_ context:any Swiftinit.VertexPageContext,
            vertex:Unidoc.ArticleVertex,
            target:String)
        {
            self.context = context
            self.vertex = vertex
            self.target = target
        }
    }
}
extension Swiftinit.ArticleCard:Swiftinit.PreviewCard
{
    var passage:Unidoc.Passage? { self.vertex.overview }
}
extension Swiftinit.ArticleCard:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.h3, { $0.class = "article" }]
        {
            $0[.a] { $0.href = self.target } = self.vertex.headline.safe
        }
        li ?= self.overview
        li[.a] { $0.href = self.target ; $0.class = "read-more" } = "Read More"
    }
}
