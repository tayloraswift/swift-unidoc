import HTML
import MarkdownABI
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Unidoc.DocsEndpoint
{
    struct ArticlePage
    {
        let sidebar:Unidoc.Sidebar<Unidoc.DocsEndpoint>
        let cone:Unidoc.Cone
        let apex:Unidoc.ArticleVertex

        init(sidebar:Unidoc.Sidebar<Unidoc.DocsEndpoint>,
            cone:Unidoc.Cone,
            apex:Unidoc.ArticleVertex)
        {
            self.sidebar = sidebar
            self.apex = apex
            self.cone = cone
        }
    }
}
extension Unidoc.DocsEndpoint.ArticlePage
{
    private
    var stem:Unidoc.Stem { self.apex.stem }
}
extension Unidoc.DocsEndpoint.ArticlePage:Unidoc.RenderablePage
{
    var title:String { "\(self.apex.headline.safe) · \(self.volume.title) documentation" }
}
extension Unidoc.DocsEndpoint.ArticlePage:Unidoc.StaticPage
{
    var location:URI { Unidoc.DocsEndpoint[self.volume, self.apex.route] }
}
extension Unidoc.DocsEndpoint.ArticlePage:Unidoc.ApplicationPage
{
}
extension Unidoc.DocsEndpoint.ArticlePage:Unidoc.ApicalPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
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

            $0 ?= self.cone.overview

            if  let file:Unidoc.Scalar = self.apex.readme
            {
                $0 ?= self.context.link(source: file)
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.context.canonical

        main[.section, { $0.class = "details literature" }] = self.cone.details

        main += self.cone.halo
    }
}
