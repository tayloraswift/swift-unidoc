import NIOCore
import NIOHTTP1

public
protocol ServerDelegateGetRequest:Sendable
{
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        with promise:() -> EventLoopPromise<ServerResponse>)
}
extension ServerDelegateGetRequest where Self == Never
{
    @inlinable public
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        with _:() -> EventLoopPromise<ServerResponse>)
    {
        nil
    }
}
