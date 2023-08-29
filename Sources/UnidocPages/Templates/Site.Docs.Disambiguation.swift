import HTML
import Unidoc
import UnidocSelectors
import UnidocRecords
import URI

extension Site.Docs
{
    struct Disambiguation
    {
        private
        let inliner:Inliner

        let identity:URI.Path
        let location:URI

        private
        let matches:[Unidoc.Scalar]
        private
        let nouns:[Volume.Noun]?

        private
        init(_ inliner:Inliner,
            identity:URI.Path,
            location:URI,
            matches:[Unidoc.Scalar],
            nouns:[Volume.Noun]?)
        {
            self.inliner = inliner

            self.identity = identity
            self.location = location
            self.matches = matches
            self.nouns = nouns
        }
    }
}
extension Site.Docs.Disambiguation
{
    init?(_ inliner:__owned Inliner,
        matches:__shared [Volume.Master],
        nouns:__owned [Volume.Noun]?)
    {
        let location:URI
        var identity:URI.Path = []

        if  let shoot:Volume.Shoot = matches.first?.shoot
        {
            location = Site.Docs[inliner.names.principal, shoot]
            identity += shoot.stem
        }
        else
        {
            return nil
        }

        self.init(inliner,
            identity: identity,
            location: location,
            matches: matches.map(\.id),
            nouns: nouns)
    }
}
extension Site.Docs.Disambiguation
{
    private
    var names:Volume.Names { self.inliner.names.principal }
}
extension Site.Docs.Disambiguation:FixedPage
{
    var title:String { "Disambiguation Page" }
}
extension Site.Docs.Disambiguation:ApplicationPage
{
    typealias Navigator = HTML.Logo

    var sidebar:Inliner.TypeTree? { self.nouns.map { .init(self.inliner, nouns: $0) } }

    var volume:VolumeIdentifier { self.names.volume }

    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span, { $0.class = "phylum" }] = "Disambiguation Page"
            }

            $0[.h1] = "\(self.identity)"

            $0[.p] = "This path could refer to multiple entities."
        }
        main[.section, { $0.class = "group choices" }]
        {
            $0[.ul]
            {
                for match:Unidoc.Scalar in self.matches
                {
                    $0 ?= self.inliner.card(match)
                }
            }
        }
    }
}
