import NIOCore
import NIOHTTP1

public
protocol ServerDelegateGetRequest:Sendable
{
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        with promise:() -> EventLoopPromise<ServerResource>)
}
extension ServerDelegateGetRequest where Self == Never
{
    @inlinable public
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        with _:() -> EventLoopPromise<ServerResource>)
    {
        nil
    }
}
