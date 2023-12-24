import Symbols
import URI

extension Swiftinit.Realm
{
    @inlinable public static
    subscript(realm:String) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append(realm)

        return uri
    }
}
