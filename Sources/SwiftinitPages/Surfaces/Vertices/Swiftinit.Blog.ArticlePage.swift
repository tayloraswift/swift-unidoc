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
        let context:IdentifiablePageContext<Swiftinit.Vertices>

        private
        let vertex:Unidoc.ArticleVertex

        init(_ context:IdentifiablePageContext<Swiftinit.Vertices>, vertex:Unidoc.ArticleVertex)
        {
            self.context = context
            self.vertex = vertex
        }
    }
}
extension Swiftinit.Blog.ArticlePage
{
    private
    var volume:Unidoc.VolumeMetadata { self.context.volume }
}
extension Swiftinit.Blog.ArticlePage:Swiftinit.RenderablePage
{
    var title:String { "\(self.vertex.headline.safe)" }

    var description:String?
    {
        self.vertex.overview.map { "\(self.context.prose($0.markdown))" }
    }
}
extension Swiftinit.Blog.ArticlePage:Swiftinit.StaticPage
{
    var location:URI
    {
        var uri:URI = []
            uri.path += self.vertex.stem
        return uri
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
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
