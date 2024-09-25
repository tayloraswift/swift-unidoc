import HTTP
import MD5
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
extension HTTP.Headers
{
    var etag:MD5?
    {
        switch self
        {
        case .http1_1(let headers): .init(header: headers["if-none-match"])
        case .http2(let headers):   .init(header: headers["if-none-match"])
        }
    }
}
