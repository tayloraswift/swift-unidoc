import HTML
import UnidocRecords

extension Unidoc
{
    struct ArticleCard
    {
        let context:any VertexContext

        let vertex:ArticleVertex
        let target:String

        init(_ context:any VertexContext, vertex:ArticleVertex, target:String)
        {
            self.context = context
            self.vertex = vertex
            self.target = target
        }
    }
}
extension Unidoc.ArticleCard:Unidoc.PreviewCard
{
    var passage:Unidoc.Passage? { self.vertex.overview }
}
extension Unidoc.ArticleCard:HTML.OutputStreamable
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
