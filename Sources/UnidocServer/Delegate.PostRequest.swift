import HTTPServer
import Multiparts
import NIOCore
import NIOHTTP1
import URI

extension Delegate
{
    struct PostRequest:Sendable
    {
        let promise:EventLoopPromise<ServerResource>
        let form:MultipartForm
        let uri:URI

        init(promise:EventLoopPromise<ServerResource>, form:MultipartForm, uri:URI)
        {
            self.promise = promise
            self.form = form
            self.uri = uri
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
                self.init(promise: promise(), form: form, uri: uri)
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
