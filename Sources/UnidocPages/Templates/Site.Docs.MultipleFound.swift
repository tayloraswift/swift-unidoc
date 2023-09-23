import HTML
import Unidoc
import UnidocSelectors
import UnidocRecords
import URI

extension Site.Docs
{
    struct MultipleFound
    {
        private
        let inliner:Inliner

        let identity:Volume.Stem

        private
        let matches:[Unidoc.Scalar]

        private
        init(_ inliner:Inliner,
            identity:Volume.Stem,
            matches:[Unidoc.Scalar])
        {
            self.inliner = inliner

            self.identity = identity
            self.matches = matches
        }
    }
}
extension Site.Docs.MultipleFound
{
    init?(_ inliner:__owned Inliner,
        matches:__shared [Volume.Vertex])
    {
        if  let stem:Volume.Stem = matches.first?.shoot?.stem
        {
            self.init(inliner, identity: stem, matches: matches.map(\.id))
        }
        else
        {
            return nil
        }

    }
}
extension Site.Docs.MultipleFound
{
    private
    var names:Volume.Names { self.inliner.names.principal }
}
extension Site.Docs.MultipleFound:RenderablePage
{
    var title:String { "Disambiguation Page - \(self.names.title)" }
}
extension Site.Docs.MultipleFound:StaticPage
{
    var location:URI
    {
        Site.Docs[self.inliner.names.principal, .init(stem: self.identity, hash: nil)]
    }
}
extension Site.Docs.MultipleFound:ApplicationPage
{
    typealias Navigator = HTML.Logo

    var volume:VolumeIdentifier { self.names.volume }

    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span, { $0.class = "phylum" }] = "Disambiguation Page"
            }

            var path:URI.Path = []
                path += self.identity

            $0[.h1] = "\(path)"

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
