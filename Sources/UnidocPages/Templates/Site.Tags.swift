import Symbols
import URI

extension Site
{
    @frozen public
    enum Tags
    {
    }
}
extension Site.Tags
{
    static
    subscript(package:Symbol.Package) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append("\(package)")

        return uri
    }
}
extension Site.Tags:StaticRoot
{
    @inlinable public static
    var root:String { "tags" }
}
