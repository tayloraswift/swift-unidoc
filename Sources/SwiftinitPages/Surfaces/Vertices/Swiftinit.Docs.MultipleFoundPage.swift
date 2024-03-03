import HTML
import Unidoc
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct MultipleFoundPage
    {
        let context:IdentifiablePageContext<Swiftinit.SecondaryOnly>

        let identity:Unidoc.Stem

        private
        let matches:[Unidoc.Scalar]

        private
        init(_ context:IdentifiablePageContext<Swiftinit.SecondaryOnly>,
            identity:Unidoc.Stem,
            matches:[Unidoc.Scalar])
        {
            self.context = context

            self.identity = identity
            self.matches = matches
        }
    }
}
extension Swiftinit.Docs.MultipleFoundPage
{
    init?(_ context:consuming IdentifiablePageContext<Swiftinit.SecondaryOnly>,
        matches:__shared [Unidoc.AnyVertex])
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
extension Swiftinit.Docs.MultipleFoundPage:Swiftinit.RenderablePage
{
    var title:String { "Disambiguation Page · \(self.volume.title) Documentation" }
}
extension Swiftinit.Docs.MultipleFoundPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, .bare(self.identity)] }
}
extension Swiftinit.Docs.MultipleFoundPage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.MultipleFoundPage:Swiftinit.VertexPage
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
            $0[.ul, { $0.class = "cards" }]
            {
                for match:Unidoc.Scalar in self.matches
                {
                    $0[.li] = self.context.card(match)
                }
            }
        }
    }
}
