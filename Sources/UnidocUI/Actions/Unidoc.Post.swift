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
    @inlinable public
    static subscript(post:Unidoc.PostAction, confirm confirm:Bool = false) -> URI
    {
        (confirm ? Unidoc.ServerRoot.really : Unidoc.ServerRoot.form) / "\(post)"
    }
}
