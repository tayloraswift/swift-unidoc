import HTML
import SwiftinitRender
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct ProductPage
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?

        private
        let vertex:Unidoc.Vertex.Product
        private
        let groups:GroupSections

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            vertex:Unidoc.Vertex.Product,
            groups:GroupSections)
        {
            self.context = context
            self.canonical = canonical
            self.vertex = vertex
            self.groups = groups
        }
    }
}
extension Swiftinit.Docs.ProductPage
{
    private
    var demonym:Swiftinit.ProductDemonym
    {
        .init(type: self.vertex.type)
    }
}
extension Swiftinit.Docs.ProductPage:Swiftinit.RenderablePage
{
    var title:String { "\(self.vertex.symbol) · \(self.volume.title) Products" }

    var description:String?
    {
        """
        \(self.vertex.symbol) is \(self.demonym.phrase) \
        available in the package \(self.volume.title)".
        """
    }
}
extension Swiftinit.Docs.ProductPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, self.vertex.shoot] }
}
extension Swiftinit.Docs.ProductPage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.ProductPage:Swiftinit.VersionedPage
{
    var sidebar:Swiftinit.Sidebar<Swiftinit.Docs>? { .package(volume: self.volume) }

    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = self.demonym.title
                $0[.span] { $0.class = "domain" } = self.context.domain
            }

            $0[.h1] = self.vertex.symbol
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical
    }
}
