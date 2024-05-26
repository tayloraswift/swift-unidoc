import HTTP
import UnidocProfiling

extension Unidoc.ServerMetrics
{
    @frozen @usableFromInline
    struct ProtocolVersion:Hashable, Sendable
    {
        let http:HTTP

        init(http:HTTP)
        {
            self.http = http
        }
    }
}
extension Unidoc.ServerMetrics.ProtocolVersion:Comparable
{
    @usableFromInline static
    func < (a:Self, b:Self) -> Bool { a.http < b.http }
}
extension Unidoc.ServerMetrics.ProtocolVersion:Identifiable
{
    @usableFromInline
    var id:String
    {
        switch self.http
        {
        case .http1_1:  return "protocol-http1-1"
        case .http2:    return "protocol-http2"
        }
    }
}
extension Unidoc.ServerMetrics.ProtocolVersion:PieSectorKey
{
    @usableFromInline
    var name:String
    {
        switch self.http
        {
        case .http1_1:  "HTTP/1.1"
        case .http2:    "HTTP/2"
        }
    }
}
