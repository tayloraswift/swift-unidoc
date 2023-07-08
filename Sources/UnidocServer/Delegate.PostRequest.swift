import HTTPServer
import Multiparts
import NIOCore
import NIOHTTP1
import URI

extension Delegate
{
    struct PostRequest:Sendable
    {
        let uri:URI
        let form:MultipartForm

        let promise:EventLoopPromise<ServerResource>

        init(_ uri:URI, form:MultipartForm, promise:EventLoopPromise<ServerResource>)
        {
            self.uri = uri
            self.form = form

            self.promise = promise
        }
    }
}
extension Delegate.PostRequest:ServerDelegatePostRequest
{
    init?(_ uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8],
        with promise:() -> EventLoopPromise<ServerResource>)
    {
        if  let uri:URI = .init(uri),
            let type:Substring = headers[canonicalForm: "content-type"].first,
            let type:ContentType = .init(type),
            case .multipart(.formData(boundary: let boundary)) = type
        {
            do
            {
                let form:MultipartForm = try .init(splitting: body, on: boundary)
                self.init(uri, form: form, promise: promise())
                return
            }
            catch
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
}
