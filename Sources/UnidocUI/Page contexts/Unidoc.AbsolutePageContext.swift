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
            guard
            let link:Unidoc.LinkReference<Unidoc.ArticleVertex> = super[article: id]
            else
            {
                return nil
            }

            return link.map
            {
                if  self.volume.id == id.edition
                {
                    //  This is a link to an article in the same volume. Most likely, the API
                    //  user wants to also host the other article under the same domain. Because
                    //  we know article paths are at most one component deep, we can just return
                    //  the last component of other article’s path as a relative URI.
                    return "../\(URI.Path.Component.push(link.vertex.stem.last.lowercased()))"
                }
                else
                {
                    return "https://swiftinit.org\($0)"
                }
            }
        }

        public override
        subscript(decl id:Unidoc.Scalar) -> Unidoc.LinkReference<Unidoc.DeclVertex>?
        {
            super[decl: id]?.map { "https://swiftinit.org\($0)" }
        }
    }
}
