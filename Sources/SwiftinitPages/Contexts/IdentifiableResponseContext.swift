import Media
import SwiftinitRender
import UnidocRecords

@frozen public
struct IdentifiableResponseContext<Vertices> where Vertices:Swiftinit.VertexCache
{
    let page:IdentifiablePageContext<Vertices>

    let canonical:CanonicalVersion?
    let format:Swiftinit.RenderFormat

    init(_ page:IdentifiablePageContext<Vertices>,
        canonical:CanonicalVersion?,
        format:Swiftinit.RenderFormat)
    {
        self.page = page
        self.canonical = canonical
        self.format = format
    }
}
