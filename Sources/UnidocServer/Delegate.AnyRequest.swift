import HTTPServer
import NIOCore
import URI

extension Delegate
{
    enum AnyRequest:Sendable
    {
        case get(GetRequest)
        case post(PostRequest)
    }
}
extension Delegate.AnyRequest
{
    var promise:EventLoopPromise<ServerResource>
    {
        switch self
        {
        case .get(let request):     return request.promise
        case .post(let request):    return request.promise
        }
    }

    var uri:URI
    {
        switch self
        {
        case .get(let request):     return request.uri
        case .post(let request):    return request.uri
        }
    }
}
