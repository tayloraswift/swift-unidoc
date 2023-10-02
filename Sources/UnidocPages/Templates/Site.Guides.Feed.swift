import HTML
import Unidoc
import UnidocSelectors
import UnidocRecords
import URI

extension Site.Guides
{
    struct Feed
    {
        let context:VersionedPageContext

        let scalars:[Unidoc.Scalar]

        private
        init(_ context:VersionedPageContext, scalars:[Unidoc.Scalar])
        {
            self.context = context
            self.scalars = scalars
        }
    }
}
extension Site.Guides.Feed
{
    init(_ context:__owned VersionedPageContext, vertices:__shared [Volume.Vertex])
    {
        self.init(context, scalars: vertices.map(\.id))
    }
}
extension Site.Guides.Feed
{
}
extension Site.Guides.Feed:RenderablePage
{
    var title:String { self.volume.title }
}
extension Site.Guides.Feed:StaticPage
{
    var location:URI { Site.Guides[self.volume] }
}
extension Site.Guides.Feed:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Guides.Feed:VersionedPage
{
    var canonical:CanonicalVersion? { nil }
    var sidebar:[Volume.Noun]? { nil }

    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.section, { $0.class = "group feed" }]
        {
            $0[.ul]
            {
                for scalar:Unidoc.Scalar in self.scalars
                {
                    $0[.li] = self.context.card(scalar)
                }
            }
        }
    }
}
