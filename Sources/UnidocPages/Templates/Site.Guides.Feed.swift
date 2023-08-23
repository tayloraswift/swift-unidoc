import HTML
import Unidoc
import UnidocSelectors
import UnidocRecords
import URI

extension Site.Guides
{
    struct Feed
    {
        private
        let inliner:Inliner

        let scalars:[Unidoc.Scalar]

        private
        init(_ inliner:Inliner, scalars:[Unidoc.Scalar])
        {
            self.inliner = inliner
            self.scalars = scalars
        }
    }
}
extension Site.Guides.Feed
{
    init(_ inliner:__owned Inliner, masters:__shared [Record.Master])
    {
        self.init(inliner, scalars: masters.map(\.id))
    }
}
extension Site.Guides.Feed
{
    private
    var zone:Record.Zone { self.inliner.zones.principal }
}
extension Site.Guides.Feed:FixedPage
{
    var location:URI { Site.Guides[self.zone] }
    var title:String { self.zone.title }
}
extension Site.Guides.Feed:ApplicationPage
{
    typealias Navigator = HTML.Logo
    typealias Sidebar = Never

    var search:URI
    {
        Site.NounMaps[self.zone]
    }

    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.section, { $0.class = "group feed" }]
        {
            $0[.ul]
            {
                for scalar:Unidoc.Scalar in self.scalars
                {
                    $0[.li] = self.inliner.card(scalar)
                }
            }
        }
    }
}
