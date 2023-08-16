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
extension Site.Guides.Feed:FixedPage
{
    var location:URI { Site.Guides[self.zone] }

    var title:String
    {
        self.zone.display ?? "\(self.zone.package)"
    }

    var zone:Record.Zone { self.inliner.zones.principal }

    func emit(header:inout HTML.ContentEncoder)
    {
    }
    func emit(content html:inout HTML.ContentEncoder)
    {
        html[.section, { $0.class = "group feed" }]
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
