import HTML
import Unidoc
import UnidocSelectors
import UnidocRecords
import URI

extension Site.Docs
{
    struct MultipleFound
    {
        let context:IdentifiablePageContext<Never?>

        let identity:Volume.Stem

        private
        let matches:[Unidoc.Scalar]

        private
        init(_ context:IdentifiablePageContext<Never?>,
            identity:Volume.Stem,
            matches:[Unidoc.Scalar])
        {
            self.context = context

            self.identity = identity
            self.matches = matches
        }
    }
}
extension Site.Docs.MultipleFound
{
    init?(_ context:consuming IdentifiablePageContext<Never?>,
        matches:__shared [Volume.Vertex])
    {
        if  let stem:Volume.Stem = matches.first?.shoot?.stem
        {
            self.init(context, identity: stem, matches: matches.map(\.id))
        }
        else
        {
            return nil
        }

    }
}
extension Site.Docs.MultipleFound:RenderablePage
{
    var title:String { "Disambiguation Page - \(self.volume.title) Documentation" }
}
extension Site.Docs.MultipleFound:StaticPage
{
    var location:URI
    {
        Site.Docs[self.volume, .init(stem: self.identity, hash: nil)]
    }
}
extension Site.Docs.MultipleFound:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.MultipleFound:VersionedPage
{
    var canonical:CanonicalVersion? { nil }
    var sidebar:Never? { nil }

    func main(_ main:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span, { $0.class = "phylum" }] = "Disambiguation Page"
                $0[.span, { $0.class = "domain" }] = self.context.domain
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
                    $0 ?= self.context.card(match)
                }
            }
        }
    }
}
