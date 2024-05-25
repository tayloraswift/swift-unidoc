import HTML
import HTTP
import HTTPServer
import IP
import NIOHPACK
import URI

extension ServerTour
{
    @frozen @usableFromInline
    struct Request:Equatable, Sendable
    {
        var version:HTTP
        var headers:HTTP.Headers
        var origin:IP.Origin
        var uri:URI

        init(
            version:HTTP,
            headers:HTTP.Headers,
            origin:IP.Origin,
            uri:URI)
        {
            self.version = version
            self.headers = headers
            self.origin = origin
            self.uri = uri
        }
    }
}
extension ServerTour.Request:HTML.OutputStreamable
{
    @usableFromInline static
    func += (dl:inout HTML.ContentEncoder, self:Self)
    {
        let uri:String = "\(self.uri)"

        dl[.dt] = "Path"
        dl[.dd] { $0[.a] { $0.href = "\(uri)" } = "\(uri)" }

        dl[.dt] = "IP address"
        dl[.dd] = "\(self.origin.address)"

        switch self.headers
        {
        case .http1_1(let headers):
            for (name, value):(String, String) in headers
            {
                dl[.dt] = name
                dl[.dd] = value
            }

        case .http2(let headers):
            for (name, value, _):(String, String, HPACKIndexing) in headers
            {
                if  case ":"? = name.first
                {
                    continue
                }

                dl[.dt] = name
                dl[.dd] = value
            }
        }
    }
}
