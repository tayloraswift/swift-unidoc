import HTTPServer
import NIOCore
import NIOHTTP1

extension Delegate
{
    struct GetRequest:Sendable
    {
        let uri:String
        let promise:EventLoopPromise<ServerResource>

        init(uri:String, promise:EventLoopPromise<ServerResource>)
        {
            self.uri = uri
            self.promise = promise
        }
    }
}
extension Delegate.GetRequest:ServerDelegateGetRequest
{
    init?(_ uri:String,
        address _:SocketAddress?,
        headers _:HTTPHeaders,
        with promise:() -> EventLoopPromise<ServerResource>)
    {
        self.init(uri: uri, promise: promise())
    }
}
