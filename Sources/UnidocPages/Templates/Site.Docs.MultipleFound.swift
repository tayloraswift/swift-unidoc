import HTML
import Unidoc
import UnidocSelectors
import UnidocRecords
import URI

extension Site.Docs
{
    struct MultipleFound
    {
        let context:VersionedPageContext

        let identity:Volume.Stem

        private
        let matches:[Unidoc.Scalar]

        private
        init(_ context:VersionedPageContext,
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
    init?(_ context:__owned VersionedPageContext,
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
    var sidebar:[Volume.Noun]? { nil }

    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span, { $0.class = "phylum" }] = "Disambiguation Page"
                $0[.span, { $0.class = "domain" }]
                {
                    $0[.span, { $0.class = "package" }]
                    {
                        $0[.a]
                        {
                            $0.href = "\(Site.Tags[self.volume.symbol.package])"
                        } = "\(self.volume.symbol.package)"
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
