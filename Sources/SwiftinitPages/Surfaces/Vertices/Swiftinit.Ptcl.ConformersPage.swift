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
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?
        let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?

        private
        let vertex:Unidoc.DeclVertex
        private
        let groups:Swiftinit.GroupLists

        private
        let stem:Unidoc.StemComponents

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?,
            vertex:Unidoc.DeclVertex,
            groups:Swiftinit.GroupLists) throws
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
    var title:String { "\(self.stem.last) · \(self.volume.title) Documentation" }

    var description:String?
    {
        if  let overview:MarkdownBytecode = self.vertex.overview?.markdown
        {
            "\(self.context.prose(overview))"
        }
        else if case .swift = self.volume.symbol.package
        {
            """
            \(self.stem.last) is \(self.demonym.phrase) from the Swift standard library.
            """
        }
        else
        {
            """
            \(self.stem.last) is \(self.demonym.phrase) from the package \(self.volume.title).
            """
        }
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
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Protocol"

                $0[.span, { $0.class = "domain" }] = self.context.subdomain(self.stem.namespace,
                    namespace: self.vertex.namespace,
                    culture: self.vertex.culture)
            }

            $0[.nav] { $0.class = "breadcrumbs" } = self.context.vector(self.vertex.scope,
                display: self.stem.scope)

            $0[.h1] = self.stem.last

            $0 ?= (self.vertex.overview?.markdown).map(self.context.prose(_:))
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main += self.groups
    }
}
