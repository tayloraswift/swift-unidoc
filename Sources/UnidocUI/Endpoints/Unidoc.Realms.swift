import UnidocRender
import URI

extension Unidoc
{
    enum Realms
    {
    }
}
extension Unidoc.Realms
{
    static
    subscript(realm:String) -> URI { Unidoc.ServerRoot.realm / realm }
}
