import HTTP
import NIOHPACK
import NIOHTTP1

extension HTTP.ServerRequest
{
    /// This type stores either ``HTTPHeaders`` or ``HPACKHeaders``, depending on the HTTP
    /// protocol version, as eagarly converting them to a common format would be wasteful.
    @frozen public
    enum Headers:Sendable
    {
        case http1_1(HTTPHeaders)
        case http2(HPACKHeaders)
    }
}
