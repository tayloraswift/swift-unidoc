import HTTPServer
import Multiparts
import NIOCore
import NIOHTTP1

extension Delegate
{
    struct PostRequest:Sendable
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
extension Delegate.PostRequest:ServerDelegatePostRequest
{
    init?(_ uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders,
        body:[ByteBuffer],
        with promise:() -> EventLoopPromise<ServerResource>)
    {
        if  let type:Substring = headers[canonicalForm: "content-type"].first,
            let type:ContentType = .init(type),
            case .multipart(.formData(boundary: let boundary)) = type
        {
            let body:[UInt8] = .init(body.lazy.map(\.readableBytesView).joined())
            if  let form:MultipartForm = try? .init(splitting: body, on: boundary)
            {
                for item:MultipartForm.Item in form
                {
                    print(item)
                }
                self.init(uri: uri, promise: promise())
                return
            }
        }
        return nil
    }
}
