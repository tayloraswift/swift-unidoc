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
    var promise:EventLoopPromise<ServerResponse>
    {
        switch self
        {
        case .get(let request):     return request.promise
        case .post(let request):    return request.promise
        }
    }
}
