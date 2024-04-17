import UnidocRender
import UnixTime
import URI

extension Swiftinit
{
    enum Telescope
    {
    }
}
extension Swiftinit.Telescope
{
    static
    subscript(date:Timestamp.Date) -> URI { Unidoc.ServerRoot.telescope / "\(date)" }

    static
    subscript(year:Timestamp.Year) -> URI { Unidoc.ServerRoot.telescope / "\(year)" }
}
