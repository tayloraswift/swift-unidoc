import HTTP
import IP
import NIOCore
import NIOHPACK
import NIOHTTP1
import URI

extension HTTP
{
    public
    protocol ServerStreamedRequest:Sendable
    {
        init?(put path:URI, headers:borrowing HPACKHeaders)

        init?(put path:URI, headers:borrowing HTTPHeaders)
    }
}
extension HTTP.ServerStreamedRequest
{
    @inlinable public
    init?(put path:URI, headers:borrowing HTTPHeaders)
    {
        self.init(put: path, headers: .init(httpHeaders: copy headers))
    }
}
