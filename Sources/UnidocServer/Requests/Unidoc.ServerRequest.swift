import HTTP
import HTTPServer
import IP
import NIOHPACK
import NIOHTTP1
import UA
import UnidocRecords
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
        let origin:ClientOrigin
        public
        let host:String?
        public
        let uri:URI

        private
        init(
            headers:HTTP.Headers,
            authorization:Authorization,
            origin:ClientOrigin,
            host:String?,
            uri:URI)
        {
            self.headers = headers
            self.authorization = authorization
            self.origin = origin
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

    /// Computes and returns the case-folded, normalized path from the ``uri``.
    var path:ArraySlice<String>
    {
        self.uri.path.normalized(lowercase: true)[...]
    }
}
extension Unidoc.ServerRequest
{
    public
    init(headers:HPACKHeaders, origin:Unidoc.ClientOrigin, uri:URI)
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
            // origin: .init(ip: request.ip) ?? .init(ip: request.ip, client: .from(headers)),
            origin: origin,
            host: host,
            uri: uri)
    }

    public
    init(headers:HTTPHeaders, origin:Unidoc.ClientOrigin, uri:URI)
    {
        self.init(headers: .http1_1(headers),
            authorization: .from(headers),
            origin: origin,
            host: headers["host"].last,
            uri: uri)
    }
}
