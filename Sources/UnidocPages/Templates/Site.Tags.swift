import ModuleGraphs
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
    subscript(package:PackageIdentifier) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append("\(package)")

        return uri
    }
}
extension Site.Tags:FixedRoot
{
    @inlinable public static
    var root:String { "tags" }
}
