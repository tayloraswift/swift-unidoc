import Availability
import FNV1
import HTML
import LexicalPaths
import MarkdownABI
import Signatures
import Sources
import Symbols
import Unidoc
import UnidocRecords
import URI

extension Swiftinit.Ptcl
{
    struct ConformersPage
    {
        let context:IdentifiablePageContext<Swiftinit.SecondaryOnly>

        let canonical:CanonicalVersion?
        let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?

        private
        let vertex:Unidoc.DeclVertex
        private
        let groups:Swiftinit.ConformingTypes

        private
        let stem:Unidoc.StemComponents

        init(_ context:IdentifiablePageContext<Swiftinit.SecondaryOnly>,
            canonical:CanonicalVersion?,
            sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?,
            vertex:Unidoc.DeclVertex,
            groups:Swiftinit.ConformingTypes) throws
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
            self.groups = groups

            self.stem = try .init(vertex.stem)
        }
    }
}
extension Swiftinit.Ptcl.ConformersPage
{
    private
    var demonym:Swiftinit.DeclDemonym
    {
        .init(phylum: self.vertex.phylum, kinks: self.vertex.kinks)
    }
}
extension Swiftinit.Ptcl.ConformersPage:Swiftinit.RenderablePage
{
    var title:String
    {
        "\(self.stem.last) (Conforming Types) · \(self.volume.title) Documentation"
    }

    var description:String?
    {
        // TODO
        nil
    }
}
extension Swiftinit.Ptcl.ConformersPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Ptcl[self.volume, self.vertex.route] }
}
extension Swiftinit.Ptcl.ConformersPage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Ptcl.ConformersPage:Swiftinit.VertexPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        let back:String = "\(Swiftinit.Docs[self.volume, self.vertex.route])"
        let name:Substring = self.stem.last

        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Conforming types"

                $0[.span, { $0.class = "domain" }] = self.context.subdomain(self.stem.namespace,
                    namespace: self.vertex.namespace,
                    culture: self.vertex.culture)
            }

            $0[.nav] { $0.class = "breadcrumbs" } = self.context.vector(self.vertex.scope,
                display: self.stem.scope)

            $0[.h1] = name

            $0[.p]
            {
                $0 += "The protocol "
                $0[.code] { $0[.a] { $0.href = back } = name }
                switch self.groups.count
                {
                case 0:
                    $0 += " has no known conforming types available."

                case 1:
                    $0 += " has one known conforming type."

                case let count:
                    $0 += " has \(count) known conforming types"

                    if  self.groups.cultures > 1
                    {
                        $0 += " across \(self.groups.cultures) modules."
                    }
                    else
                    {
                        $0 += "."
                    }
                }
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main += self.groups
    }
}
