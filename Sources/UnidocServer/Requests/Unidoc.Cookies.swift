import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct Cookie
    {
        let name:Substring
        let value:Substring

        init(name:Substring = "", value:Substring)
        {
            self.name = name
            self.value = value
        }
    }
}
extension Unidoc.Cookie
{
    init?(_ cookie:Substring)
    {
        if  let equals:String.Index = cookie.firstIndex(of: "=")
        {
            let start:String.Index = cookie.index(after: equals)
            self.init(name: cookie[..<equals], value: cookie[start...])
        }
        else if !cookie.isEmpty
        {
            self.init(value: cookie)
        }
        else
        {
            return nil
        }
    }
}
extension Unidoc.Cookie
{
    static
    var session:String { "__Host-session" }

    static
    var login:String { "login_state" }
}
