import HTML
import MarkdownRendering
import UnidocSelectors
import UnidocRecords
import URI

extension Site.Blog
{
    struct Article
    {
        private
        let context:VersionedPageContext

        private
        let vertex:Volume.Vertex.Article

        init(_ context:VersionedPageContext, vertex:Volume.Vertex.Article)
        {
            self.context = context
            self.vertex = vertex
        }
    }
}
extension Site.Blog.Article
{
    private
    var volume:Volume.Meta { self.context.volumes.principal }
}
extension Site.Blog.Article:RenderablePage
{
    var title:String { self.volume.title }
}
extension Site.Blog.Article:StaticPage
{
    var location:URI
    {
        var uri:URI = []
            uri.path += self.vertex.stem
        return uri
    }

    public
    func body(_ body:inout HTML.ContentEncoder)
    {
        body[.header]
        {
            $0[.div, { $0.class = "content" }] { $0[.nav] = HTML.Logo.init() }
        }
        body[.div]
        {
            $0[.main, { $0.class = "content" }]
            {
                $0[.section, { $0.class = "introduction" }]
                {
                    $0[.h1] = self.vertex.headline.safe

                }
                $0[.section, { $0.class = "details" }]
                {
                    $0 ?= (self.vertex.overview?.markdown).map(self.context.prose(_:))
                    $0 ?= (self.vertex.details?.markdown).map(self.context.prose(_:))
                }
            }
        }
    }
}
