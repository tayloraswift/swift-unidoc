import UnidocDB
import UnidocRecords

extension Swiftinit
{
    struct Cookies:Equatable, Hashable, Sendable
    {
        var session:Unidoc.Cookie?
        var login:String?

        init()
        {
            self.session = nil
            self.login = nil
        }
    }
}
extension Swiftinit.Cookies
{
    static
    var session:String { "__Host-session" }

    static
    var login:String { "login_state" }
}
extension Swiftinit.Cookies
{
    init(header lines:[String])
    {
        self.init()
        for line:String in lines
        {
            for cookie:Substring in line.split(separator: ";")
            {
                let cookie:Substring = cookie.drop(while: \.isWhitespace)
                if  let equals:Substring.Index = cookie.firstIndex(of: "=")
                {
                    let start:Substring.Index = cookie.index(after: equals)
                    self.update(cookie[..<equals], with: cookie[start...])
                }
                else if !cookie.isEmpty
                {
                    self.update(with: cookie)
                }
            }
        }
    }

    private mutating
    func update(_ name:Substring = "", with value:Substring)
    {
        switch name
        {
        case Self.session:  self.session = .init(value)
        case Self.login:    self.login = .init(value)
        case _:             break
        }
    }
}
