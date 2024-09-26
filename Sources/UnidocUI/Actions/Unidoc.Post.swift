import UnidocRender
import URI

extension Unidoc
{
    @frozen public
    enum Post
    {
    }
}
extension Unidoc.Post
{
    static subscript(package id:Unidoc.Package, scope:Unidoc.PackageMetadataSettings) -> URI
    {
        var uri:URI = Unidoc.ServerRoot.form.uri

        uri.path.append(Unidoc.PostAction.package)
        uri.path.append(id)
        uri.path.append(scope)

        return uri
    }

    @inlinable public
    static subscript(post:Unidoc.PostAction, confirm confirm:Bool = false) -> URI
    {
        (confirm ? Unidoc.ServerRoot.really : Unidoc.ServerRoot.form) / "\(post)"
    }
}
