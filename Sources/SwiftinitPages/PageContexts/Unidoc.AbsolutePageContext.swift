import SwiftinitRender
import UnidocRecords

extension Unidoc
{
    public final
    class AbsolutePageContext:IdentifiablePageContext<Vertices>
    {
        public override
        subscript(vertex id:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, url:String?)?
        {
            super[vertex: id].map { ($0.vertex, $0.url.map { "https://swiftinit.org\($0)" }) }
        }

        public override
        subscript(culture id:Unidoc.Scalar) -> (vertex:Unidoc.CultureVertex, url:String?)?
        {
            super[culture: id].map { ($0.vertex, $0.url.map { "https://swiftinit.org\($0)" }) }
        }

        public override
        subscript(article id:Unidoc.Scalar) -> (vertex:Unidoc.ArticleVertex, url:String?)?
        {
            super[article: id].map { ($0.vertex, $0.url.map { "https://swiftinit.org\($0)" }) }
        }

        public override
        subscript(decl id:Unidoc.Scalar) -> (vertex:Unidoc.DeclVertex, url:String?)?
        {
            super[decl: id].map { ($0.vertex, $0.url.map { "https://swiftinit.org\($0)" }) }
        }
    }
}
