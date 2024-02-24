import HTML
import MarkdownABI
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct ArticlePage
    {
        let context:IdentifiablePageContext<Swiftinit.Vertices>

        let canonical:CanonicalVersion?
        let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?

        private
        let vertex:Unidoc.ArticleVertex
        private
        let groups:Swiftinit.GroupLists


        init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
            canonical:CanonicalVersion?,
            sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?,
            vertex:Unidoc.ArticleVertex,
            groups:Swiftinit.GroupLists)
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
            self.groups = groups
        }
    }
}
extension Swiftinit.Docs.ArticlePage
{
    private
    var stem:Unidoc.Stem { self.vertex.stem }
}
extension Swiftinit.Docs.ArticlePage:Swiftinit.RenderablePage
{
    var title:String { "\(self.vertex.headline.safe) · \(self.volume.title) Documentation" }

    var description:String?
    {
        self.vertex.overview.map { "\(self.context.prose($0.markdown))" }
    }
}
extension Swiftinit.Docs.ArticlePage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, self.vertex.route] }
}
extension Swiftinit.Docs.ArticlePage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.ArticlePage:Swiftinit.VertexPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Article"

                $0[.span, { $0.class = "domain" }] = self.context.subdomain(self.stem.first,
                    culture: self.vertex.culture)
            }

            $0[.h1] = self.vertex.headline.safe

            $0 ?= (self.vertex.overview?.markdown).map(self.context.prose(_:))

            if  let file:Unidoc.Scalar = self.vertex.readme
            {
                $0 ?= self.context.link(source: file)
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main[.section, { $0.class = "details literature" }] =
            (self.vertex.details?.markdown).map(self.context.prose(_:))

        main += self.groups
    }
}
