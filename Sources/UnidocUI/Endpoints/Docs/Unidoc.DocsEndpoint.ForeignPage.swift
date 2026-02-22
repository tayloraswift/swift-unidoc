import HTML
import LexicalPaths
import MarkdownRendering
import Symbols
import Unidoc
import UnidocRecords
import URI

extension Unidoc.DocsEndpoint {
    struct ForeignPage {
        let cone: Unidoc.Cone
        let apex: Unidoc.ForeignVertex

        private let stem: Unidoc.StemComponents

        init(cone: Unidoc.Cone, apex: Unidoc.ForeignVertex) throws {
            self.cone = cone
            self.apex = apex

            self.stem = try .init(self.apex.stem)
        }
    }
}
extension Unidoc.DocsEndpoint.ForeignPage {
    private var demonym: Unidoc.DeclDemonym {
        .init(phylum: self.apex.phylum, kinks: self.apex.kinks)
    }
}
extension Unidoc.DocsEndpoint.ForeignPage: Unidoc.RenderablePage {
    var title: String { "\(self.stem.last) (ext) · \(self.volume.title) documentation" }
}
extension Unidoc.DocsEndpoint.ForeignPage: Unidoc.StaticPage {
    var location: URI { Unidoc.DocsEndpoint[self.volume, self.apex.route] }
}
extension Unidoc.DocsEndpoint.ForeignPage: Unidoc.ApicalPage {
    var descriptionFallback: String {
        """
        \(self.stem.last), \(self.demonym.phrase) from \(self.stem.namespace), has extensions \
        available in the package \(self.volume.title)").
        """
    }

    var sidebar: Unidoc.Sidebar<Unidoc.DocsEndpoint> { .package(volume: self.volume) }

    func main(_ main: inout HTML.ContentEncoder, format: Unidoc.RenderFormat) {
        main[.header, { $0.class = "hero" }] {
            $0[.div, { $0.class = "eyebrows" }] {
                $0[.span] { $0.class = "phylum" } = "Extension (\(self.demonym.title))"
                $0[.span] { $0.class = "domain" } = self.context.volume | nil
            }

            $0[.nav] {
                $0.class = "breadcrumbs"
            } = Unidoc.LinkVector.init(
                self.context,
                display: self.stem.scope,
                scalars: self.apex.scope
            )

            $0[.h1] = "\(self.stem.last) (ext)"
        }

        let extendee: HTML.Link<UnqualifiedPath>? = self.context.link(decl: self.apex.extendee)
        if  let other: Unidoc.VolumeMetadata = self.context[self.apex.extendee.edition] {
            main[.section, { $0.class = "notice extendee" }] {
                $0[.p] {
                    $0 += "You’re viewing third-party extensions to "
                    $0[.code] = extendee
                    $0 += ", \(self.demonym.phrase) from "

                    $0[.a] {
                        $0.href = "\(Unidoc.DocsEndpoint[other])"
                    } = other.symbol.package == .swift
                        ? "the Swift standard library"
                        : other.title

                    $0 += "."
                }

                $0[.p] {
                    $0 += """
                    You can also read the documentation for
                    """
                    $0[.code] = extendee
                    $0 += " itself."
                }
            }
        }

        main[.pre, { $0.class = "declaration" }] {
            $0[.code] {
                $0[.span] { $0.highlight = .keyword } = "extension"
                $0 += " "
                $0[link: extendee?.target] { $0.class = "extendee" } = self.stem.last
            }
        }

        main[.footer] = self.cone.halo
    }
}
