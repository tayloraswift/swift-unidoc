import UnidocRender
import UnidocRecords

extension Unidoc
{
    public final
    class InternalBlogContext:IdentifiablePageContext<IdentifiableVertices>
    {
        public override
        subscript(vertex id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.AnyVertex>?
        {
            if  case (let vertex, principal: false)? = self.vertices[id],
                case .article(let article) = vertex,
                self.volume.id == article.id.edition
            {
                //  These won’t produce tooltips yet...
                return .init(vertex: vertex, target: .relative(sibling: article))
            }
            else
            {
                return super[vertex: id]
            }
        }

        public override
        subscript(article id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.ArticleVertex>?
        {
            if  case (.article(let article), principal: false)? = self.vertices[id],
                self.volume.id == article.id.edition
            {
                return .init(vertex: article, target: .relative(sibling: article))
            }
            else
            {
                return super[article: id]
            }
        }
    }
}
