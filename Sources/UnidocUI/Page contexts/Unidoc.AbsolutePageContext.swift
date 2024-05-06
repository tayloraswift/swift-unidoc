import UnidocRender
import UnidocRecords
import URI

extension Unidoc
{
    public final
    class AbsolutePageContext:IdentifiablePageContext<IdentifiableVertices>
    {
        public override
        subscript(vertex id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.AnyVertex>?
        {
            guard
            let link:Unidoc.LinkReference<Unidoc.AnyVertex> = super[vertex: id]
            else
            {
                return nil
            }

            if  case .article(let article) = link.vertex
            {
                return link.map { self.rewrite($0, to: article) }
            }
            else
            {
                return link.map(Self.rewrite(_:))
            }
        }

        public override
        subscript(article id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.ArticleVertex>?
        {
            guard
            let link:Unidoc.LinkReference<Unidoc.ArticleVertex> = super[article: id]
            else
            {
                return nil
            }

            return link.map { self.rewrite($0, to: link.vertex) }
        }

        public override
        subscript(culture id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.CultureVertex>?
        {
            super[culture: id]?.map(Self.rewrite(_:))
        }

        public override
        subscript(decl id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.DeclVertex>?
        {
            super[decl: id]?.map(Self.rewrite(_:))
        }
    }
}
extension Unidoc.AbsolutePageContext
{
    @inline(__always)
    private static
    func rewrite(_ uri:String) -> String
    {
        "https://swiftinit.org\(uri)"
    }

    private
    func rewrite(_ uri:String, to article:Unidoc.ArticleVertex) -> String
    {
        if  self.volume.id == article.id.edition
        {
            //  This is a link to an article in the same volume. Most likely, the API
            //  user wants to also host the other article under the same domain. Because
            //  we know article paths are at most one component deep, we can just return
            //  the last component of the other article’s path as a relative URI.
            return "../\(URI.Path.Component.push(article.stem.last.lowercased()))"
        }
        else
        {
            return Self.rewrite(uri)
        }
    }
}
