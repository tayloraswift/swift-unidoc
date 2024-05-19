import HTTP
import HTTPServer
import IP
import NIOHPACK
import NIOHTTP1
import UA
import UnidocProfiling
import UnidocRecords

extension Unidoc.IntegralRequest
{
    @frozen public
    struct Metadata:Sendable
    {
        public
        let annotation:Unidoc.ClientAnnotation
        let cookies:Unidoc.Cookies

        public
        let version:HTTP
        public
        let headers:HTTP.ProfileHeaders
        public
        let origin:IP.Origin
        public
        let host:String?
        public
        let path:String

        private
        init(
            annotation:Unidoc.ClientAnnotation,
            cookies:Unidoc.Cookies,
            version:HTTP,
            headers:HTTP.ProfileHeaders,
            origin:IP.Origin,
            host:String?,
            path:String)
        {
            self.annotation = annotation
            self.cookies = cookies

            self.version = version
            self.headers = headers
            self.origin = origin
            self.host = host
            self.path = path
        }
    }
}
extension Unidoc.IntegralRequest.Metadata
{
    var hostSupportsPublicAPI:Bool
    {
        switch self.host
        {
        case "api.swiftinit.org"?:   true
        case "localhost"?:           true
        default:                     false
        }
    }
    var logged:ServerTour.Request
    {
        .init(
            version: self.version,
            headers: self.headers,
            origin: self.origin,
            path: self.path)
    }

    var credentials:Unidoc.Credentials
    {
        .init(cookies: self.cookies, request: self.path)
    }
}
extension Unidoc.IntegralRequest.Metadata
{
    public
    init(headers:borrowing HPACKHeaders, origin:IP.Origin, path:String)
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

        let headers:HTTP.ProfileHeaders = .init(
            acceptLanguage: headers["accept-language"].last,
            userAgent: headers["user-agent"].last,
            referer: headers["referer"].last)

        self.init(
            annotation: .guess(headers: headers, owner: origin.owner),
            cookies: .init(header: cookies),
            version: .http2,
            headers: headers,
            origin: origin,
            host: host,
            path: path)
    }

    public
    init(headers:borrowing HTTPHeaders, origin:IP.Origin, path:String)
    {
        let host:String? = headers["host"].last
        let headers:HTTP.ProfileHeaders = .init(
            acceptLanguage: headers["accept-language"].last,
            userAgent: headers["user-agent"].last,
            referer: headers["referer"].last)

        //  None of our authenticated endpoints support HTTP/1.1, so there is no
        //  need to load cookies.
        self.init(
            annotation: .guess(headers: headers, owner: origin.owner),
            cookies: .init(),
            version: .http1_1,
            headers: headers,
            origin: origin,
            host: host,
            path: path)

        if  case .robot(.discoursebot) = self.annotation
        {
            Log[.debug] = """
            Approved possible Swift Forums robot
                User-Agent: '\(headers.userAgent ?? "")'
                IP Address: \(origin.address)
            """
        }
    }
}
