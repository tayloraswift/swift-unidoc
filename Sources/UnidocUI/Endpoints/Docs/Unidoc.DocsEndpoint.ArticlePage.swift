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

        private
        let culture:Unidoc.LinkReference<Unidoc.CultureVertex>

        init(cone:Unidoc.Cone, apex:Unidoc.ArticleVertex, tree:Unidoc.TypeTree?) throws
        {
            self.cone = cone
            self.apex = apex

            self.culture = try self.cone.context[culture: self.apex.culture]
            self.sidebar = .module(
                volume: self.cone.context.volume,
                origin: self.culture.vertex.module.id,
                tree: tree)
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
    var title:String
    {
        self.culture.vertex.headline.map
        {
            "\(self.apex.headline.safe) · \($0.safe)"
        } ?? "\(self.apex.headline.safe) · \(self.volume.title) documentation"
    }
}
extension Unidoc.DocsEndpoint.ArticlePage:Unidoc.StaticPage
{
    var location:URI { Unidoc.DocsEndpoint[self.volume, self.apex.route] }
}
extension Unidoc.DocsEndpoint.ArticlePage:Unidoc.ApicalPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.header, { $0.class = "hero" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Article"
                $0[.span] { $0.class = "domain" } = self.context.volume | self.culture
            }

            $0[.h1] = self.apex.headline.safe
            $0[.time] { $0.class = "byline" } = self.context.byline(format.locale)
            $0[.div] { $0.class = "docc" } = self.cone.overview

            if  let file:Unidoc.Scalar = self.apex.readme
            {
                $0 ?= self.context.link(source: file)
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.context.canonical

        main[.div] { $0.class = "docc" } = self.cone.details

        main[.footer] = self.cone.halo
    }
}
