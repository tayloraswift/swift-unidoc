import IP
import NIOCore
import NIOHPACK
import NIOHTTP1

public
protocol HTTPServerStreamedRequest:Sendable
{
    init?(put path:String,
        headers:HPACKHeaders,
        address:IP.V6)

    init?(put path:String,
        headers:HTTPHeaders,
        address:IP.V6)
}
extension HTTPServerStreamedRequest
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
