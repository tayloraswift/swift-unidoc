import HTTP
import HTTPServer
import IP
import NIOHPACK
import NIOHTTP1
import UA
import UnidocProfiling
import UnidocRecords
import URI

extension Unidoc.IntegralRequest
{
    @frozen public
    struct Metadata:Sendable
    {
        public
        let annotation:Unidoc.ClientAnnotation

        let headers:HTTP.Headers
        let cookies:Unidoc.Cookies

        public
        let origin:IP.Origin
        public
        let host:String?
        public
        let uri:URI

        private
        init(
            headers:HTTP.Headers,
            cookies:Unidoc.Cookies,
            origin:IP.Origin,
            host:String?,
            uri:URI)
        {
            self.annotation = .guess(headers: headers, owner: origin.owner)
            self.headers = headers
            self.cookies = cookies
            self.origin = origin
            self.host = host
            self.uri = uri
        }
    }
}
extension Unidoc.IntegralRequest.Metadata
{
    /// Computes and returns the case-folded, normalized path from the ``uri``.
    var path:ArraySlice<String>
    {
        self.uri.path.normalized(lowercase: true)[...]
    }
}
extension Unidoc.IntegralRequest.Metadata
{
    var version:HTTP
    {
        switch self.headers
        {
        case .http1_1:  .http1_1
        case .http2:    .http2
        }
    }

    var logged:ServerTour.Request
    {
        .init(
            version: self.version,
            headers: self.headers,
            origin: self.origin,
            uri: self.uri)
    }

    var credentials:Unidoc.Credentials
    {
        .init(cookies: self.cookies, request: self.uri)
    }
}
extension Unidoc.IntegralRequest.Metadata
{
    public
    init(headers:HPACKHeaders, origin:IP.Origin, uri:URI)
    {
        let cookies:[String] = headers["cookie"]
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
            cookies: .init(header: cookies),
            origin: origin,
            host: host,
            uri: uri)
    }

    public
    init(headers:HTTPHeaders, origin:IP.Origin, uri:URI)
    {
        let host:String? = headers["host"].last

        //  None of our authenticated endpoints support HTTP/1.1, so there is no
        //  need to load cookies.
        self.init(headers: .http1_1(headers),
            cookies: .init(),
            origin: origin,
            host: host,
            uri: uri)
    }
}
