import URI
import UnixTime

extension Swiftinit.Telescope
{
    @inlinable internal static
    subscript(date:Timestamp.Date) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append("\(date)")

        return uri
    }

    @inlinable internal static
    subscript(year:Timestamp.Year) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append("\(year)")

        return uri
    }
}
