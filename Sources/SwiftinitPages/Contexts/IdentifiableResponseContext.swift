import Media
import SwiftinitRender
import Unidoc

@frozen public
struct IdentifiableResponseContext
{
    let page:IdentifiablePageContext<Unidoc.Scalar>

    let canonical:CanonicalVersion?
    let format:Swiftinit.RenderFormat

    init(_ page:IdentifiablePageContext<Unidoc.Scalar>,
        canonical:CanonicalVersion?,
        format:Swiftinit.RenderFormat)
    {
        self.page = page
        self.canonical = canonical
        self.format = format
    }
}
