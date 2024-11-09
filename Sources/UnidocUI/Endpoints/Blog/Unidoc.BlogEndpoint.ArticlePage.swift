import HTML
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Unidoc.BlogEndpoint
{
    struct ArticlePage
    {
        private
        let context:Unidoc.InternalBlogContext
        private
        let prose:Unidoc.Prose
        private
        let apex:Unidoc.ArticleVertex

        init(context:Unidoc.InternalBlogContext, apex:Unidoc.ArticleVertex)
        {
            self.context = context
            self.prose = .init(apex: apex)
            self.apex = apex
        }
    }
}
extension Unidoc.BlogEndpoint.ArticlePage
{
    private
    var volume:Unidoc.VolumeMetadata { self.context.volume }
}
extension Unidoc.BlogEndpoint.ArticlePage:Unidoc.RenderablePage
{
    var title:String { "\(self.apex.headline.safe)" }

    var description:String?
    {
        self.prose.overviewText(with: self.context.vertices)?.description
    }

    func head(augmenting head:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        //  We need this for the relative links to work.
        head[.base] { $0.href = "\(self.location)/" ; $0.target = "_self" }
    }
}
extension Unidoc.BlogEndpoint.ArticlePage:Unidoc.StaticPage
{
    var location:URI
    {
        var uri:URI = []
            uri.path += self.apex.stem
        return uri
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        body[.div, { $0.class = "app navigator" }]
        {
            $0[.header]
            {
                $0[.nav] = format.cornice
            }
        }

        body[.div, { $0.class = "app" }]
        {
            $0[.main]
            {
                $0[.section, { $0.class = "introduction" }]
                {
                    $0[.h1] = self.apex.headline.safe

                }
                $0[.section, { $0.class = "details literature" }]
                {
                    $0 ?= self.prose.overview(with: self.context)
                    $0 ?= self.prose.details(with: self.context)
                }
            }
        }

        body[.div]
        {
            $0.style = "display: none;"
            $0.id = "ss:tooltips"
        } = self.context.tooltips
    }
}
