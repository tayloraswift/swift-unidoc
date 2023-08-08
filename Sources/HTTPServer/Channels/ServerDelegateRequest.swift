import NIOCore
import NIOHTTP1

public
protocol ServerDelegateRequest:Sendable
{
    init?(get uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        with promise:() -> EventLoopPromise<ServerResponse>)

    init?(post uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8],
        with promise:() -> EventLoopPromise<ServerResponse>)
}
extension ServerDelegateRequest
{
    @inlinable public
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        with _:() -> EventLoopPromise<ServerResponse>)
    {
        nil
    }

    @inlinable public
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8],
        with _:() -> EventLoopPromise<ServerResponse>)
    {
        nil
    }
}
