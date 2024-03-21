import HTTP
import IP
import NIOCore
import NIOHPACK
import NIOHTTP1

extension HTTP
{
    public
    protocol ServerIntegralRequest:Sendable
    {
        init?(get path:String,
            headers:borrowing HPACKHeaders,
            address:IP.V6,
            service:IP.Service?)

        init?(get path:String,
            headers:borrowing HTTPHeaders,
            address:IP.V6,
            service:IP.Service?)

        init?(post path:String,
            headers:borrowing HPACKHeaders,
            address:IP.V6,
            service:IP.Service?,
            body:borrowing [UInt8])

        init?(post path:String,
            headers:borrowing HTTPHeaders,
            address:IP.V6,
            service:IP.Service?,
            body:consuming [UInt8])
    }
}
extension HTTP.ServerIntegralRequest
{
    @inlinable public
    init?(get path:String,
        headers:borrowing HTTPHeaders,
        address:IP.V6,
        service:IP.Service?)
    {
        self.init(get: path,
            headers: .init(httpHeaders: copy headers),
            address: address,
            service: service)
    }

    @inlinable public
    init?(post path:String,
        headers:borrowing HTTPHeaders,
        address:IP.V6,
        service:IP.Service?,
        body:consuming [UInt8])
    {
        self.init(post: path,
            headers: .init(httpHeaders: copy headers),
            address: address,
            service: service,
            body: body)
    }
}
