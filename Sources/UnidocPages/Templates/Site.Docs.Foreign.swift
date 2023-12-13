import HTML
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Site.Docs
{
    struct Foreign
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?

        private
        let vertex:Volume.Vertex.Foreign
        private
        let groups:GroupSections

        private
        let stem:Volume.StemComponents

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            vertex:Volume.Vertex.Foreign,
            groups:GroupSections) throws
        {
            self.context = context
            self.canonical = canonical
            self.vertex = vertex
            self.groups = groups

            self.stem = try .init(vertex.stem)
        }
    }
}
extension Site.Docs.Foreign
{
    private
    var demonym:Unidoc.Decl.Demonym<Language.EN>
    {
        .init(phylum: self.vertex.phylum, kinks: self.vertex.kinks)
    }
}
extension Site.Docs.Foreign:RenderablePage
{
    var title:String { "\(self.stem.last) (ext) - \(self.volume.title) Documentation" }

    var description:String?
    {
        """
        \(self.stem.last), \(self.demonym.phrase) from \(self.stem.namespace), has extensions \
        available in the package \(self.volume.title)").
        """
    }
}
extension Site.Docs.Foreign:StaticPage
{
    var location:URI { Site.Docs[self.volume, self.vertex.shoot] }
}
extension Site.Docs.Foreign:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.Foreign:VersionedPage
{
    var sidebar:HTML.Sidebar<Site.Docs>? { .package(volume: self.context.volume) }

    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Extension (\(self.demonym.title))"
                $0[.span] { $0.class = "domain" } = self.context.domain
            }

            $0[.nav] { $0.class = "breadcrumbs" } = self.context.vector(self.vertex.scope,
                display: self.stem.scope)

            $0[.h1] = "\(self.stem.last) (ext)"
        }

        let extendee:HTML.Link<String>? = self.context.link(decl: self.vertex.extendee)
        if  let other:Volume.Metadata = self.context.volumes[self.vertex.extendee.zone]
        {
            main[.section, { $0.class = "notice extendee" }]
            {
                $0[.p]
                {
                    $0 += "You’re viewing third-party extensions to "
                    $0[.code] { $0[link: extendee?.target] = self.stem.last }
                    $0 += ", \(self.demonym.phrase) from "

                    $0[.a] { $0.href = "\(Site.Docs[other])" } = other.symbol.package == .swift
                        ? "the Swift standard library"
                        : other.title

                    $0 += "."
                }

                $0[.p]
                {
                    $0 += """
                    You can also read the documentation for
                    """
                    $0[.code] { $0[link: extendee?.target] = self.stem.last }
                    $0 += " itself."
                }
            }
        }

        main[.section, { $0.class = "declaration" }]
        {
            $0[.pre]
            {
                $0[.code]
                {
                    $0[.span] { $0.highlight = .keyword } = "extension"
                    $0 += " "
                    $0[link: extendee?.target] { $0.class = "extendee" } = self.stem.last
                }
            }
        }

        main += self.groups
    }
}
