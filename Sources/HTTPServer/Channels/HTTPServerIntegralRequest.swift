import IP
import NIOCore
import NIOHTTP1
import NIOHPACK

public
protocol HTTPServerIntegralRequest:Sendable
{
    init?(get path:String,
        headers:HPACKHeaders,
        address:IP.V6)

    init?(get path:String,
        headers:HTTPHeaders,
        address:IP.V6)

    init?(post path:String,
        headers:HPACKHeaders,
        address:IP.V6,
        body:[UInt8])

    init?(post path:String,
        headers:HTTPHeaders,
        address:IP.V6,
        body:[UInt8])
}
extension HTTPServerIntegralRequest
{
    @inlinable public
    init?(get path:String,
        headers:HTTPHeaders,
        address:IP.V6)
    {
        self.init(get: path,
            headers: .init(httpHeaders: headers),
            address: address)
    }

    @inlinable public
    init?(post path:String,
        headers:HTTPHeaders,
        address:IP.V6,
        body:[UInt8])
    {
        self.init(post: path,
            headers: .init(httpHeaders: headers),
            address: address,
            body: body)
    }
}
