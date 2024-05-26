import HTTP
import UnidocProfiling

extension Unidoc.ServerMetrics
{
    @frozen @usableFromInline
    struct Status:Equatable, Hashable, Sendable
    {
        let code:UInt

        private
        init(code:UInt)
        {
            self.code = code
        }
    }
}
extension Unidoc.ServerMetrics.Status
{
    static
    func of(_ response:HTTP.ServerResponse) -> Self
    {
        switch response
        {
        case .resource(let resource, status: let status):
            if  case nil = resource.content,
                case 200 = status
            {
                return .init(code: 304)
            }
            else
            {
                return .init(code: status)
            }

        case .redirect(let redirect, _):
            return .init(code: redirect.status)
        }
    }
}
extension Unidoc.ServerMetrics.Status:Comparable
{
    @usableFromInline static
    func < (a:Self, b:Self) -> Bool { a.code < b.code }
}
extension Unidoc.ServerMetrics.Status:Identifiable
{
    @usableFromInline
    var id:String { "status-\(self.code)" }
}
extension Unidoc.ServerMetrics.Status:PieSectorKey
{
    @usableFromInline
    var name:String
    {
        switch self.code
        {
        case 200:       "200 OK"
        case 300:       "300 Multiple Choices"
        case 303:       "303 See Other"
        case 304:       "304 Not Modified"
        case 307:       "307 Temporary Redirect"
        case 308:       "308 Permanent Redirect"
        case 404:       "404 Not Found"
        case 410:       "410 Gone"
        case 500:       "500 Internal Server Error"
        case let code:  "\(code)"
        }
    }
}
