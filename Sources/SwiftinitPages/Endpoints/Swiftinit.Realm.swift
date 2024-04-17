import UnidocRender
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
    subscript(realm:String) -> URI { Unidoc.ServerRoot.realm / realm }
}
