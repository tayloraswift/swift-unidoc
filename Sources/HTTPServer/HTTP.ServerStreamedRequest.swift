import HTTP
import IP
import NIOCore
import NIOHPACK
import NIOHTTP1

extension HTTP
{
    public
    protocol ServerStreamedRequest:Sendable
    {
        init?(put path:String, headers:borrowing HPACKHeaders)

        init?(put path:String, headers:borrowing HTTPHeaders)
    }
}
extension HTTP.ServerStreamedRequest
{
    @inlinable public
    init?(put path:String, headers:borrowing HTTPHeaders)
    {
        self.init(put: path, headers: .init(httpHeaders: copy headers))
    }
}
