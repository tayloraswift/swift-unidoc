import HTTP
import HTTPServer
import IP
import NIOHPACK
import NIOHTTP1
import UnidocRecords
import UnixTime
import URI

extension Unidoc
{
    /// A ``ServerRequest`` is a request that has not yet been routed to an operation through
    /// a `Router`.
    @dynamicMemberLookup
    @frozen public
    struct ServerRequest:Sendable
    {
        public
        let metadata:HTTP.ServerRequest
        public
        let authorization:Authorization
        public
        let accepted:UnixAttosecond
        public
        let client:ClientGuess?

        private
        init(metadata:HTTP.ServerRequest,
            authorization:Authorization,
            accepted:UnixAttosecond,
            client:ClientGuess?)
        {
            self.metadata = metadata
            self.authorization = authorization
            self.accepted = accepted
            self.client = client
        }
    }
}
extension Unidoc.ServerRequest
{
    @inlinable public
    subscript<T>(dynamicMember keyPath:KeyPath<HTTP.ServerRequest, T>) -> T
    {
        self.metadata[keyPath: keyPath]
    }

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
        switch self.origin.claimant
        {
        case .google_common?:
            return .majorSearchEngine(.googlebot, verified: true)

        case .microsoft_bingbot?:
            return .majorSearchEngine(.bingbot, verified: true)

        default:
            break
        }

        switch self.client
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
    init(metadata:HTTP.ServerRequest, client:Unidoc.ClientGuess?)
    {
        self.init(metadata: metadata,
            authorization: metadata.headers.authorization,
            accepted: .now(),
            client: client)
    }
}
