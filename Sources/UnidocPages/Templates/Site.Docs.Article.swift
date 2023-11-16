import HTML
import MarkdownABI
import MarkdownRendering
import UnidocRecords
import Unidoc
import URI

extension Site.Docs
{
    struct Article
    {
        let context:VersionedPageContext

        let canonical:CanonicalVersion?
        let sidebar:[Volume.Noun]?

        private
        let vertex:Volume.Vertex.Article
        private
        let groups:GroupSections


        init(_ context:VersionedPageContext,
            canonical:CanonicalVersion?,
            sidebar:[Volume.Noun]?,
            vertex:Volume.Vertex.Article,
            groups:GroupSections)
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
            self.groups = groups
        }
    }
}
extension Site.Docs.Article
{
    private
    var stem:Volume.Stem { self.vertex.stem }
}
extension Site.Docs.Article:RenderablePage
{
    var title:String { "\(self.vertex.headline.safe) - \(self.volume.title) Documentation" }

    var description:String?
    {
        self.vertex.overview.map { "\(self.context.prose($0.markdown))" }
    }
}
extension Site.Docs.Article:StaticPage
{
    var location:URI { Site.Docs[self.volume, self.vertex.shoot] }
}
extension Site.Docs.Article:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.Article:VersionedPage
{
    func main(_ main:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Article"

                $0[.span, { $0.class = "domain" }]
                {
                    $0[.span, { $0.class = "culture" }]
                    {
                        $0[link: self.context.url(self.vertex.culture)] = self.stem.first
                    }

                    $0[.span, { $0.class = "volume" }]
                    {
                        $0[.a]
                        {
                            $0.href = "\(Site.Docs[self.volume])"
                        } = self.volume.symbol.version
                    }
                }
            }

            $0[.h1] = self.vertex.headline.safe

            $0 ?= (self.vertex.overview?.markdown).map(self.context.prose(_:))

            if  let file:Unidoc.Scalar = self.vertex.file
            {
                $0 ?= self.context.link(file: file)
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main[.section, { $0.class = "details" }] =
            (self.vertex.details?.markdown).map(self.context.prose(_:))

        main += self.groups
    }
}
