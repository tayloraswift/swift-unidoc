import HTTP
import NIOHTTP1
import NIOHPACK

extension HTTP
{
    @frozen public
    enum Headers:Equatable, Sendable
    {
        case http1_1(HTTPHeaders)
        case http2(HPACKHeaders)
    }
}
