import UnidocRender
import UnidocRecords

extension Unidoc
{
    public final
    class AbsolutePageContext:IdentifiablePageContext<IdentifiableVertices>
    {
        public override
        subscript(vertex id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.AnyVertex>?
        {
            super[vertex: id]?.map { "https://swiftinit.org\($0)" }
        }

        public override
        subscript(culture id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.CultureVertex>?
        {
            super[culture: id]?.map { "https://swiftinit.org\($0)" }
        }

        public override
        subscript(article id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.ArticleVertex>?
        {
            super[article: id]?.map { "https://swiftinit.org\($0)" }
        }

        public override
        subscript(decl id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.DeclVertex>?
        {
            super[decl: id]?.map { "https://swiftinit.org\($0)" }
        }
    }
}
