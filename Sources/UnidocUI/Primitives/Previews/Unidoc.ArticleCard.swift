import HTML
import UnidocRecords

extension Unidoc {
    struct ArticleCard: PreviewCard {
        let context: any VertexContext

        let vertex: ArticleVertex
        let target: LinkTarget

        init(_ context: any VertexContext, vertex: ArticleVertex, target: LinkTarget) {
            self.context = context
            self.vertex = vertex
            self.target = target
        }
    }
}
extension Unidoc.ArticleCard: HTML.OutputStreamable {
    static func += (li: inout HTML.ContentEncoder, self: Self) {
        li[.h3, { $0.class = "article" }] {
            $0[.a] { $0.tooltip = .omit ; $0.link = self.target } = self.vertex.headline.safe
        }
        li ?= self.overview
        li[.a] {
            $0.tooltip = .omit
            $0.link = self.target
            $0.class = "read-more"
        } = "Read More"
    }
}
