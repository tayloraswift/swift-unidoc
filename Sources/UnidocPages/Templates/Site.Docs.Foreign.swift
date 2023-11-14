import HTML
import MarkdownRendering
import ModuleGraphs
import Unidoc
import UnidocRecords
import URI

extension Site.Docs
{
    struct Foreign
    {
        let context:VersionedPageContext

        let canonical:CanonicalVersion?

        private
        let vertex:Volume.Vertex.Foreign
        private
        let groups:[Volume.Group]

        init(_ context:VersionedPageContext,
            canonical:CanonicalVersion?,
            vertex:Volume.Vertex.Foreign,
            groups:[Volume.Group])
        {
            self.context = context
            self.canonical = canonical
            self.vertex = vertex
            self.groups = groups
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

    private
    var stem:Volume.Stem { self.vertex.stem }
}
extension Site.Docs.Foreign:RenderablePage
{
    var title:String { "\(self.stem.last) (ext) - \(self.volume.title) Documentation" }

    var description:String?
    {
        """
        \(self.stem.last), \(self.demonym.phrase) from \(self.stem.first), has extensions \
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
    var navigator:Breadcrumbs
    {
        if  let (_, scope, last):(Substring, [Substring], Substring) = self.stem.split()
        {
            .init(scope: self.vertex.scope.isEmpty ?
                    nil : self.context.vectorLink(components: scope, to: self.vertex.scope),
                last: last)
        }
        else
        {
            .init(scope: nil,
                last: self.stem.last)
        }
    }
}
extension Site.Docs.Foreign:VersionedPage
{
    var sidebar:[Volume.Noun]? { self.context.volumes.principal.tree }

    func main(_ main:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Extension (\(self.demonym.title))"
                $0[.span] { $0.class = "domain" } = self.volume.domain
            }

            $0[.h1] = "\(self.stem.last) (ext)"
        }

        let extendee:HTML.Link<String>? = self.context.link(decl: self.vertex.extendee)
        if  let other:Volume.Meta = self.context.volumes[self.vertex.extendee.zone]
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

        main += GroupSections.init(self.context,
            groups: self.groups,
            bias: nil,
            mode: .decl(self.vertex.flags.phylum, self.vertex.flags.kinks))
    }
}
