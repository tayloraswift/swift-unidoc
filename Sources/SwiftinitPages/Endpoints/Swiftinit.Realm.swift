import Swiftinit
import Symbols
import URI

extension Swiftinit
{
    enum Realm
    {
    }
}
extension Swiftinit.Realm
{
    static
    subscript(realm:String) -> URI { Swiftinit.Root.realm / realm }
}
