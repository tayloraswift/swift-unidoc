import Symbols
import URI

extension Swiftinit.Tags
{
    static
    subscript(package:Symbol.Package) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append("\(package)")

        return uri
    }
}
