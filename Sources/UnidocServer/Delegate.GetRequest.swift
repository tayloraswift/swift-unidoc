import HTTPServer
import NIOCore
import NIOHTTP1
import URI

extension Delegate
{
    struct GetRequest:Sendable
    {
        let promise:EventLoopPromise<ServerResource>

        let parameters:Parameters
        let path:[String]

        let uri:URI

        init(promise:EventLoopPromise<ServerResource>, uri:URI)
        {
            self.promise = promise
            self.uri = uri

            self.parameters = .init(uri.query)
            self.path = uri.path.normalized()
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
            self.init(promise: promise(), uri: uri)
        }
        else
        {
            return nil
        }
    }
}
