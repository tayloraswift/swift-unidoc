import Swiftinit
import URI
import UnixTime

extension Swiftinit
{
    enum Telescope
    {
    }
}
extension Swiftinit.Telescope
{
    static
    subscript(date:Timestamp.Date) -> URI { Swiftinit.Root.telescope / "\(date)" }

    static
    subscript(year:Timestamp.Year) -> URI { Swiftinit.Root.telescope / "\(year)" }
}
