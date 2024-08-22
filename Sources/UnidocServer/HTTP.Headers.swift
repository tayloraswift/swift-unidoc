import HTTP
import NIOHPACK
import NIOHTTP1

extension HTTP
{
    @frozen public
    enum Headers:Equatable, Sendable
    {
        case http1_1(HTTPHeaders)
        case http2(HPACKHeaders)
    }
}
