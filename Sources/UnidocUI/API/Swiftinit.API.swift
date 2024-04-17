import UnidocRender
import URI

extension Swiftinit
{
    @frozen public
    enum API
    {
    }
}
extension Swiftinit.API
{
    @inlinable public static
    subscript(post:Post, really really:Bool = true) -> URI
    {
        (really ? Unidoc.ServerRoot.api : Unidoc.ServerRoot.really) / "\(post)"
    }
}
