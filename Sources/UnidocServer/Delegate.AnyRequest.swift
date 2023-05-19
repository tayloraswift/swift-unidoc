import HTTPServer
import NIOCore

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
}
