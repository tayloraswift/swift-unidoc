import HTML
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Swiftinit.Blog
{
    struct ArticlePage
    {
        private
        let cone:Unidoc.Cone
        private
        let apex:Unidoc.ArticleVertex

        init(cone:Unidoc.Cone, apex:Unidoc.ArticleVertex)
        {
            self.cone = cone
            self.apex = apex
        }
    }
}
extension Swiftinit.Blog.ArticlePage
{
    private
    var volume:Unidoc.VolumeMetadata { self.cone.halo.context.volume }
}
extension Swiftinit.Blog.ArticlePage:Swiftinit.RenderablePage
{
    var title:String { "\(self.apex.headline.safe)" }

    var description:String? { self.cone.overview?.description }
}
extension Swiftinit.Blog.ArticlePage:Swiftinit.StaticPage
{
    var location:URI
    {
        var uri:URI = []
            uri.path += self.apex.stem
        return uri
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        body[.header]
        {
            $0[.div, { $0.class = "content" }] { $0[.nav] = HTML.Logo.init() }
        }
        body[.div, { $0.class = "app" }]
        {
            $0[.main, { $0.class = "content" }]
            {
                $0[.section, { $0.class = "introduction" }]
                {
                    $0[.h1] = self.apex.headline.safe

                }
                $0[.section, { $0.class = "details literature" }]
                {
                    $0 ?= self.cone.overview
                    $0 ?= self.cone.details
                }
            }
        }
    }
}
