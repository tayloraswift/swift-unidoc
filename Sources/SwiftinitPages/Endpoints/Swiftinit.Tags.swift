import Symbols
import UnidocRender
import URI

extension Swiftinit
{
    @frozen public
    enum Tags
    {
    }
}
extension Swiftinit.Tags
{
    @inlinable public static
    subscript(package:Symbol.Package) -> URI { Unidoc.ServerRoot.tags / "\(package)" }

    @inlinable public static
    subscript(package:Symbol.Package, page index:Int, beta betas:Bool = false) -> URI
    {
        var uri:URI = Unidoc.ServerRoot.tags / "\(package)"
        uri["page"] = "\(index)"
        uri["beta"] = betas ? "true" : nil
        return uri
    }
}
