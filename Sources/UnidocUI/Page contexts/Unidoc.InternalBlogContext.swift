import UnidocRecords
import UnidocRender

extension Unidoc {
    public final class InternalBlogContext: IdentifiablePageContext<IdentifiableVertices> {
        public override subscript(
            vertex id: Unidoc.Scalar
        ) -> Unidoc.LinkReference<Unidoc.AnyVertex>? {
            if  case (let vertex, principal: false)? = self.vertices[id],
                case .article(let article) = vertex,
                let relative: Unidoc.LinkTarget = .relative(
                    target: article,
                    base: self.vertices.principal
                ) {
                //  These won’t produce tooltips yet...
                return .init(vertex: vertex, target: relative)
            } else {
                return super[vertex: id]
            }
        }

        public override subscript(
            article id: Unidoc.Scalar
        ) -> Unidoc.LinkReference<Unidoc.ArticleVertex>? {
            if  case (.article(let article), principal: false)? = self.vertices[id],
                let relative: Unidoc.LinkTarget = .relative(
                    target: article,
                    base: self.vertices.principal
                ) {
                return .init(vertex: article, target: relative)
            } else {
                return super[article: id]
            }
        }
    }
}
