import HTML
import SwiftinitRender
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct Product
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
extension Swiftinit.Docs.Product:Swiftinit.RenderablePage
{
    var title:String { "\(self.vertex.symbol) · \(self.volume.title) Products" }

    var description:String?
    {
        """
        \(self.vertex.symbol) is a product available in the package \(self.volume.title)").
        """
    }
}
extension Swiftinit.Docs.Product:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, self.vertex.shoot] }
}
extension Swiftinit.Docs.Product:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.Product:Swiftinit.VersionedPage
{
    var sidebar:Swiftinit.Sidebar<Swiftinit.Docs>? { .package(volume: self.volume) }

    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        //  TODO: unimplemented
    }
}
