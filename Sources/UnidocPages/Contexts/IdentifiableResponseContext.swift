import Media
import Unidoc

@frozen public
struct IdentifiableResponseContext
{
    let page:IdentifiablePageContext<Unidoc.Scalar>

    let canonical:CanonicalVersion?
    let format:Unidoc.RenderFormat

    init(_ page:IdentifiablePageContext<Unidoc.Scalar>,
        canonical:CanonicalVersion?,
        format:Unidoc.RenderFormat)
    {
        self.page = page
        self.canonical = canonical
        self.format = format
    }
}
