import Swiftinit
import Symbols
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
    subscript(package:Symbol.Package) -> URI { Swiftinit.Root.tags / "\(package)" }
}
