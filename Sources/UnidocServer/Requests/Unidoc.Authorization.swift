import Fingerprinting
import HTTP
import NIOHPACK
import NIOHTTP1
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    enum Authorization:Sendable
    {
        case web(UserSession.Web?, login:String?)
        case api(UserSession.API)
        case invalid(AuthorizationHeaderError)
    }
}
extension Unidoc.Authorization
{
    private static
    func web(cookie lines:[String]) -> Self
    {
        var loginSession:Unidoc.UserSession.Web? = nil
        var loginState:String? = nil

        for line:String in lines
        {
            for cookie:HTTP.Cookie in HTTP.CookieList.init(line)
            {
                switch cookie.name
                {
                case Unidoc.Cookie.loginSession:    loginSession = .init(cookie.value)
                case Unidoc.Cookie.loginState:      loginState = .init(cookie.value)
                case _:                             continue
                }
            }
        }

        return .web(loginSession, login: loginState)
    }

    private static
    func api(authorization header:String) -> Self
    {
        guard
        let space:String.Index = header.firstIndex(of: " ")
        else
        {
            return .invalid(.scheme(header[...]))
        }

        guard case "unidoc" = header[..<space].lowercased()
        else
        {
            return .invalid(.scheme(header[..<space]))
        }

        let credentials:Substring = header[header.index(after: space)...].drop(
            while: \.isWhitespace)

        guard
        let session:Unidoc.UserSession.API = .init(credentials)
        else
        {
            return .invalid(.format(credentials))
        }

        return .api(session)
    }
}
extension Unidoc.Authorization
{
    static
    func from(_ headers:HTTPHeaders) -> Self
    {
        if  let authorization:String = headers["authorization"].last
        {
            .api(authorization: authorization)
        }
        else
        {
            .web(cookie: headers["cookie"])
        }
    }

    static
    func from(_ headers:HPACKHeaders) -> Self
    {
        if  let authorization:String = headers["authorization"].last
        {
            .api(authorization: authorization)
        }
        else
        {
            .web(cookie: headers["cookie"])
        }
    }
}
extension Unidoc.Authorization
{
    var account:Unidoc.Account?
    {
        switch self
        {
        case .web(let session, _):  session?.id
        case .api(let session):     session.id
        case .invalid:              nil
        }
    }
}
