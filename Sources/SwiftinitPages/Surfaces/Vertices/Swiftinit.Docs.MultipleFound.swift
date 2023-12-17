import HTML
import Unidoc
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct MultipleFound
    {
        let context:IdentifiablePageContext<Never?>

        let identity:Unidoc.Stem

        private
        let matches:[Unidoc.Scalar]

        private
        init(_ context:IdentifiablePageContext<Never?>,
            identity:Unidoc.Stem,
            matches:[Unidoc.Scalar])
        {
            self.context = context

            self.identity = identity
            self.matches = matches
        }
    }
}
extension Swiftinit.Docs.MultipleFound
{
    init?(_ context:consuming IdentifiablePageContext<Never?>,
        matches:__shared [Unidoc.Vertex])
    {
        if  let stem:Unidoc.Stem = matches.first?.shoot?.stem
        {
            self.init(context, identity: stem, matches: matches.map(\.id))
        }
        else
        {
            return nil
        }

    }
}
extension Swiftinit.Docs.MultipleFound:Swiftinit.RenderablePage
{
    var title:String { "Disambiguation Page · \(self.volume.title) Documentation" }
}
extension Swiftinit.Docs.MultipleFound:Swiftinit.StaticPage
{
    var location:URI
    {
        Swiftinit.Docs[self.volume, .init(stem: self.identity, hash: nil)]
    }
}
extension Swiftinit.Docs.MultipleFound:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.MultipleFound:Swiftinit.VersionedPage
{
    var canonical:CanonicalVersion? { nil }
    var sidebar:Never? { nil }

    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
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
