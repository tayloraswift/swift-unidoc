import UnidocRecords
import UnidocRender

extension Unidoc
{
    public final
    class ExternalBlogContext:IdentifiablePageContext<IdentifiableVertices>
    {
        public override
        subscript(vertex id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.AnyVertex>?
        {
            guard
            var link:Unidoc.LinkReference<Unidoc.AnyVertex> = super[vertex: id]
            else
            {
                return nil
            }

            if  case .article(let article) = link.vertex
            {
                link.target?.export(as: article, base: self.vertices.principal)
            }
            else
            {
                link.target?.export()
            }

            return link
        }

        public override
        subscript(article id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.ArticleVertex>?
        {
            if  var link:Unidoc.LinkReference<Unidoc.ArticleVertex> = super[article: id]
            {
                link.target?.export(as: link.vertex, base: self.vertices.principal)
                return link
            }
            else
            {
                return nil
            }
        }

        public override
        subscript(culture id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.CultureVertex>?
        {
            if  var link:Unidoc.LinkReference<Unidoc.CultureVertex> = super[culture: id]
            {
                link.target?.export()
                return link
            }
            else
            {
                return nil
            }
        }

        public override
        subscript(decl id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.DeclVertex>?
        {
            if  var link:Unidoc.LinkReference<Unidoc.DeclVertex> = super[decl: id]
            {
                link.target?.export()
                return link
            }
            else
            {
                return nil
            }
        }
    }
}
