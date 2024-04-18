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
    @inlinable public static
    subscript(post:Unidoc.PostAction, really really:Bool = true) -> URI
    {
        (really ? Unidoc.ServerRoot.api : Unidoc.ServerRoot.really) / "\(post)"
    }
}
