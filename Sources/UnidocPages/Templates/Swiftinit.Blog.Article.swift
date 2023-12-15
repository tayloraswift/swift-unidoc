import HTML
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Swiftinit.Blog
{
    struct Article
    {
        private
        let context:IdentifiablePageContext<Unidoc.Scalar>

        private
        let vertex:Unidoc.Vertex.Article

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>, vertex:Unidoc.Vertex.Article)
        {
            self.context = context
            self.vertex = vertex
        }
    }
}
extension Swiftinit.Blog.Article
{
    private
    var volume:Unidoc.VolumeMetadata { self.context.volumes.principal }
}
extension Swiftinit.Blog.Article:RenderablePage
{
    var title:String { "\(self.volume.title) Documentation" }
}
extension Swiftinit.Blog.Article:StaticPage
{
    var location:URI
    {
        var uri:URI = []
            uri.path += self.vertex.stem
        return uri
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
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
