import HTTP
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
        let address:IP.V6
        let service:IP.Service?
        let path:String

        init(
            annotation:Swiftinit.ClientAnnotation,
            cookies:Swiftinit.Cookies,
            version:HTTP,
            headers:HTTP.ProfileHeaders,
            address:IP.V6,
            service:IP.Service?,
            path:String)
        {
            self.annotation = annotation
            self.cookies = cookies

            self.version = version
            self.headers = headers
            self.address = address
            self.service = service
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
            path: path)
    }

    init(
        headers:borrowing HTTPHeaders,
        address:IP.V6,
        service:IP.Service?,
        path:String)
    {
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
            path: path)
    }
}
