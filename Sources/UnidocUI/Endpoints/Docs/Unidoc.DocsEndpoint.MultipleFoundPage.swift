import HTML
import Unidoc
import UnidocRecords
import URI

extension Unidoc.DocsEndpoint {
    struct MultipleFoundPage {
        let context: Unidoc.PeripheralPageContext

        let identity: Unidoc.Stem

        private let matches: [Unidoc.Scalar]

        private init(
            _ context: Unidoc.PeripheralPageContext,
            identity: Unidoc.Stem,
            matches: [Unidoc.Scalar]
        ) {
            self.context = context

            self.identity = identity
            self.matches = matches
        }
    }
}
extension Unidoc.DocsEndpoint.MultipleFoundPage {
    init?(
        _ context: consuming Unidoc.PeripheralPageContext,
        matches: __shared [Unidoc.AnyVertex]
    ) {
        if  let stem: Unidoc.Stem = matches.first?.shoot?.stem {
            self.init(context, identity: stem, matches: matches.map(\.id))
        } else {
            return nil
        }

    }
}
extension Unidoc.DocsEndpoint.MultipleFoundPage: Unidoc.RenderablePage {
    var title: String { "Disambiguation page · \(self.volume.title) documentation" }
}
extension Unidoc.DocsEndpoint.MultipleFoundPage: Unidoc.StaticPage {
    var location: URI { Unidoc.DocsEndpoint[self.volume, .bare(self.identity)] }
}
extension Unidoc.DocsEndpoint.MultipleFoundPage: Unidoc.VertexPage {
    /// TODO: give this type a better sidebar
    var sidebar: String { "" }

    func main(_ main: inout HTML.ContentEncoder, format: Unidoc.RenderFormat) {
        main[.header, { $0.class = "hero" }] {
            $0[.div, { $0.class = "eyebrows" }] {
                $0[.span] { $0.class = "phylum" } = "Disambiguation Page"
                $0[.span] { $0.class = "domain" } = self.context.volume | nil
            }

            var path: URI.Path = []
            path += self.identity

            $0[.h1] = "\(path)"

            $0[.p] = "This path could refer to multiple entities."
        }
        main[.footer] {
            $0[.section, { $0.class = "group choices" }] {
                $0[.ul, { $0.class = "cards" }] {
                    for match: Unidoc.Scalar in self.matches {
                        $0[.li] = self.context.card(match)
                    }
                }
            }
        }
    }
}
