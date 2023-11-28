import Media
import Unidoc

@frozen public
struct IdentifiableResponseContext
{
    let page:IdentifiablePageContext<Unidoc.Scalar>

    let canonical:CanonicalVersion?
    let assets:StaticAssets
    let accept:AcceptType

    init(
        _ page:IdentifiablePageContext<Unidoc.Scalar>,
        canonical:CanonicalVersion?,
        assets:StaticAssets,
        accept:AcceptType)
    {
        self.page = page
        self.canonical = canonical
        self.assets = assets
        self.accept = accept
    }
}
