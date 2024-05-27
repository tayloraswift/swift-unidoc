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
    func web(header lines:[String]) -> Self
    {
        var session:Unidoc.UserSession.Web? = nil
        var login:String? = nil

        for line:String in lines
        {
            for cookie:Substring in line.split(separator: ";")
            {
                guard
                let cookie:Unidoc.Cookie = .init(cookie.drop(while: \.isWhitespace))
                else
                {
                    continue
                }

                switch cookie.name
                {
                case Unidoc.Cookie.session: session = .init(cookie.value)
                case Unidoc.Cookie.login:   login = .init(cookie.value)
                case _:                     continue
                }
            }
        }

        return .web(session, login: login)
    }

    private static
    func api(header:String) -> Self
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
            .api(header: authorization)
        }
        else
        {
            .web(header: headers["cookie"])
        }
    }

    static
    func from(_ headers:HPACKHeaders) -> Self
    {
        if  let authorization:String = headers["authorization"].last
        {
            .api(header: authorization)
        }
        else
        {
            .web(header: headers["cookie"])
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
