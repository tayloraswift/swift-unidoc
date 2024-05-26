import NIOHPACK
import NIOHTTP1
import UnidocRecords

extension Unidoc
{
    @frozen public
    enum Authorization:Sendable
    {
        case web(Cookies)
        case api(Account, Int64)
        case invalid(AuthorizationHeaderError)
    }
}
extension Unidoc.Authorization
{
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
        let separator:String.Index = credentials.firstIndex(of: "_"),
        let account:Unidoc.Account = .init(credentials[..<separator]),
        let key:UInt64 = .init(credentials[credentials.index(after: separator)...], radix: 16)
        else
        {
            return .invalid(.format(credentials))
        }

        return .api(account, .init(bitPattern: key))
    }

    static
    func from(_ headers:HTTPHeaders) -> Self
    {
        if  let authorization:String = headers["authorization"].last
        {
            .api(header: authorization)
        }
        else
        {
            .web(.init(header: headers["cookie"]))
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
            .web(.init(header: headers["cookie"]))
        }
    }
}
extension Unidoc.Authorization
{
    var cookies:Unidoc.Cookies
    {
        switch self
        {
        case .web(let cookies): return cookies
        case .api:              return .init()
        case .invalid:          return .init()
        }
    }
}
