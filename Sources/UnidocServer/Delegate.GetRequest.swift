import HTTPServer
import NIOCore
import NIOHTTP1
import URI

extension Delegate
{
    struct GetRequest:Sendable
    {
        let uri:URI
        let promise:EventLoopPromise<ServerResource>

        init(uri:URI, promise:EventLoopPromise<ServerResource>)
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
        if  let uri:URI = .init(uri)
        {
            self.init(uri: uri, promise: promise())
        }
        else
        {
            return nil
        }
    }
}
