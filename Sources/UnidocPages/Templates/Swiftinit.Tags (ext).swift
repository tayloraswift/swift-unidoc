import Symbols
import URI

extension Swiftinit.Tags
{
    @inlinable public static
    subscript(package:Symbol.Package) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append("\(package)")

        return uri
    }
}
