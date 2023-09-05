import NIOCore
import NIOHTTP1

public
protocol HTTPServerOperation:Sendable
{
    init?(get uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders)

    init?(post uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8])
}
extension HTTPServerOperation
{
    @inlinable public
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders)
    {
        nil
    }

    @inlinable public
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8])
    {
        nil
    }
}
