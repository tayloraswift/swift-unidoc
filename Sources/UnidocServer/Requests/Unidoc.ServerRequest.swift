import HTTP
import HTTPServer
import IP
import NIOHPACK
import NIOHTTP1
import UA
import UnidocRecords
import UnixTime
import URI

extension Unidoc
{
    /// A ``ServerRequest`` is a request that has not yet been routed to an operation through
    /// a `Router`.
    @frozen public
    struct ServerRequest:Sendable
    {
        public
        let headers:HTTP.Headers

        public
        let authorization:Authorization
        public
        let accepted:UnixAttosecond
        public
        let client:ClientOrigin
        public
        let host:String?
        public
        let uri:URI

        private
        init(
            headers:HTTP.Headers,
            authorization:Authorization,
            accepted:UnixAttosecond,
            client:ClientOrigin,
            host:String?,
            uri:URI)
        {
            self.headers = headers
            self.authorization = authorization
            self.accepted = accepted
            self.client = client
            self.host = host
            self.uri = uri
        }
    }
}
extension Unidoc.ServerRequest
{
    func parameter(_ key:String) -> String?
    {
        guard
        let query:URI.Query = self.uri.query
        else
        {
            return nil
        }

        for case (key, let value) in query.parameters
        {
            return value
        }

        return nil
    }

    var privilege:Unidoc.ClientPrivilege?
    {
        switch self.client.origin.claimant
        {
        case .google_common?:
            return .majorSearchEngine(.googlebot, verified: true)

        case .microsoft_bingbot?:
            return .majorSearchEngine(.bingbot, verified: true)

        default:
            break
        }

        switch self.client.guess
        {
        case .barbie(let locale)?:
            if  case .web(_?, login: _) = self.authorization
            {
                return .barbie(locale, verified: true)
            }
            else
            {
                return .barbie(locale, verified: false)
            }

        case .robot(.yandexbot)?:
            return .majorSearchEngine(.yandexbot, verified: false)

        default:
            return nil
        }
    }
}
extension Unidoc.ServerRequest
{
    public
    init(headers:HPACKHeaders, client:Unidoc.ClientOrigin, uri:URI)
    {
        let host:String? = headers[":authority"].last.map
        {
            if  let colon:String.Index = $0.lastIndex(of: ":")
            {
                return String.init($0[..<colon])
            }
            else
            {
                return $0
            }
        }

        self.init(headers: .http2(headers),
            authorization: .from(headers),
            accepted: .now(),
            client: client,
            host: host,
            uri: uri)
    }

    public
    init(headers:HTTPHeaders, client:Unidoc.ClientOrigin, uri:URI)
    {
        self.init(headers: .http1_1(headers),
            authorization: .from(headers),
            accepted: .now(),
            client: client,
            host: headers["host"].last,
            uri: uri)
    }
}
