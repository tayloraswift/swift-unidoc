import HTTP
import HTTPServer
import IP
import NIOHPACK
import NIOHTTP1
import UA
import UnidocProfiling
import UnidocRecords

extension Swiftinit.IntegralRequest
{
    struct Metadata:Sendable
    {
        let annotation:Swiftinit.ClientAnnotation
        let cookies:Swiftinit.Cookies

        let version:HTTP
        let headers:HTTP.ProfileHeaders
        /// What IP address did the request come from?
        let address:IP.V6
        /// Who owns the IP ``address``?
        let service:IP.Service?
        let host:String?
        let path:String

        private
        init(
            annotation:Swiftinit.ClientAnnotation,
            cookies:Swiftinit.Cookies,
            version:HTTP,
            headers:HTTP.ProfileHeaders,
            address:IP.V6,
            service:IP.Service?,
            host:String?,
            path:String)
        {
            self.annotation = annotation
            self.cookies = cookies

            self.version = version
            self.headers = headers
            self.address = address
            self.service = service
            self.host = host
            self.path = path
        }
    }
}
extension Swiftinit.IntegralRequest.Metadata
{
    var logged:ServerTour.Request
    {
        .init(
            version: self.version,
            headers: self.headers,
            address: self.address,
            service: self.service,
            path: self.path)
    }
}
extension Swiftinit.IntegralRequest.Metadata
{
    init(
        headers:borrowing HPACKHeaders,
        address:IP.V6,
        service:IP.Service?,
        path:String)
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
            annotation: .guess(service: service, headers: headers),
            cookies: .init(header: cookies),
            version: .http2,
            headers: headers,
            address: address,
            service: service,
            host: host,
            path: path)
    }

    init(
        headers:borrowing HTTPHeaders,
        address:IP.V6,
        service:IP.Service?,
        path:String)
    {
        let host:String? = headers["host"].last
        let headers:HTTP.ProfileHeaders = .init(
            acceptLanguage: headers["accept-language"].last,
            userAgent: headers["user-agent"].last,
            referer: headers["referer"].last)

        //  None of our authenticated endpoints support HTTP/1.1, so there is no
        //  need to load cookies.
        self.init(
            annotation: .guess(service: service, headers: headers),
            cookies: .init(),
            version: .http1_1,
            headers: headers,
            address: address,
            service: service,
            host: host,
            path: path)

        if  case .robot(.discoursebot) = self.annotation
        {
            Log[.debug] = """
            Approved possible Swift Forums robot
                User-Agent: '\(headers.userAgent ?? "")'
                IP Address: \(address)
            """
        }
    }
}
