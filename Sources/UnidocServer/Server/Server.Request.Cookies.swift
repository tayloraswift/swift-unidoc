
extension Server.Request
{
    struct Cookies:Equatable, Hashable, Sendable
    {
        var session:String?
        var login:String?

        private
        init()
        {
            self.session = nil
            self.login = nil
        }
    }
}
extension Server.Request.Cookies
{
    init(_ lines:[Substring])
    {
        self.init()
        for line:Substring in lines
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
        case "session":     self.session = .init(value)
        case "login_state": self.login = .init(value)
        case _:             break
        }
    }
}
