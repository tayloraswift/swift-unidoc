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
    init?(put path:String,
        headers:HPACKHeaders,
        address:IP.V6)

    init?(put path:String,
        headers:HTTPHeaders,
        address:IP.V6)
}
extension HTTP.ServerStreamedRequest
{
    @inlinable public
    init?(put path:String,
        headers:HTTPHeaders,
        address:IP.V6)
    {
        self.init(put: path,
            headers: .init(httpHeaders: headers),
            address: address)
    }
}
