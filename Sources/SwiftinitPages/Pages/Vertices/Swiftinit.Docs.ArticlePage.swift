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
        let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?
        let mesh:Swiftinit.Mesh
        let apex:Unidoc.ArticleVertex

        init(sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?,
            mesh:Swiftinit.Mesh,
            apex:Unidoc.ArticleVertex)
        {
            self.sidebar = sidebar
            self.apex = apex
            self.mesh = mesh
        }
    }
}
extension Swiftinit.Docs.ArticlePage
{
    private
    var stem:Unidoc.Stem { self.apex.stem }
}
extension Swiftinit.Docs.ArticlePage:Swiftinit.RenderablePage
{
    var title:String { "\(self.apex.headline.safe) · \(self.volume.title) Documentation" }
}
extension Swiftinit.Docs.ArticlePage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, self.apex.route] }
}
extension Swiftinit.Docs.ArticlePage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.ArticlePage:Swiftinit.ApicalPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Article"

                $0[.span, { $0.class = "domain" }] = self.context.subdomain(self.stem.first,
                    culture: self.apex.culture)
            }

            $0[.h1] = self.apex.headline.safe

            $0 ?= self.mesh.overview

            if  let file:Unidoc.Scalar = self.apex.readme
            {
                $0 ?= self.context.link(source: file)
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.context.canonical

        main[.section, { $0.class = "details literature" }] = self.mesh.details

        main += self.mesh.halo
    }
}
