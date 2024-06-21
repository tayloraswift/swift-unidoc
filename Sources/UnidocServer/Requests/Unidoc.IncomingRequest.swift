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
    /// An `IncomingRequest` is a request that has not yet been routed to an operation through
    /// a ``Router``.
    @frozen public
    struct IncomingRequest:Sendable
    {
        public
        let headers:HTTP.Headers

        public
        let authorization:Authorization
        public
        let origin:Origin
        public
        let host:String?
        public
        let uri:URI

        private
        init(
            headers:HTTP.Headers,
            authorization:Authorization,
            origin:Origin,
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
extension Unidoc.IncomingRequest
{
    /// Computes and returns the case-folded, normalized path from the ``uri``.
    var path:ArraySlice<String>
    {
        self.uri.path.normalized(lowercase: true)[...]
    }
}
extension Unidoc.IncomingRequest
{
    public
    init(headers:HPACKHeaders, origin:IP.Origin, uri:URI)
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
            origin: .init(ip: origin) ?? .init(ip: origin, client: .from(headers)),
            host: host,
            uri: uri)
    }

    public
    init(headers:HTTPHeaders, origin:IP.Origin, uri:URI)
    {
        self.init(headers: .http1_1(headers),
            authorization: .from(headers),
            origin: .init(ip: origin) ?? .init(ip: origin, client: .from(headers)),
            host: headers["host"].last,
            uri: uri)
    }
}
