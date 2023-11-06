import HTTP
import IP
import NIOCore
import NIOHPACK
import NIOHTTP1

extension HTTP
{
    public
    typealias ServerStreamedRequest = _HTTPServerStreamedRequest
}

@available(*, deprecated, renamed: "HTTP.ServerStreamedRequest")
public
typealias HTTPServerStreamedRequest = HTTP.ServerStreamedRequest


public
protocol _HTTPServerStreamedRequest:Sendable
{
    init?(put path:String, headers:borrowing HPACKHeaders)

    init?(put path:String, headers:borrowing HTTPHeaders)
}
extension HTTP.ServerStreamedRequest
{
    @inlinable public
    init?(put path:String, headers:borrowing HTTPHeaders)
    {
        self.init(put: path, headers: .init(httpHeaders: copy headers))
    }
}
