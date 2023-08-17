import HTTPServer
import Media
import MD5
import Multiparts
import NIOCore
import NIOHTTP1
import UnidocPages
import URI

extension Server
{
    struct Request:Sendable
    {
        let operation:AnyOperation
        let promise:EventLoopPromise<ServerResponse>

        init(operation:AnyOperation, promise:EventLoopPromise<ServerResponse>)
        {
            self.operation = operation
            self.promise = promise
        }
    }
}
extension Server.Request:ServerDelegateRequest
{
    init?(get uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders,
        with promise:() -> EventLoopPromise<ServerResponse>)
    {
        guard let uri:URI = .init(uri)
        else
        {
            return nil
        }

        let path:[String] = uri.path.normalized(lowercase: true)
        let tag:MD5? = headers.ifNoneMatch.first.flatMap(MD5.init(_:))

        if  let root:Int = path.indices.first,
            let get:AnyOperation = .get(
                root: path[root],
                rest: path[path.index(after: root)...],
                uri: uri,
                tag: tag)
        {
            self.init(operation: get, promise: promise())
        }
        else
        {
            return nil
        }
    }

    init?(post uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8],
        with promise:() -> EventLoopPromise<ServerResponse>)
    {
        guard let uri:URI = .init(uri)
        else
        {
            return nil
        }

        let path:[String] = uri.path.normalized(lowercase: true)
        let form:MultipartForm?

        if  let type:Substring = headers[canonicalForm: "content-type"].first,
            let type:ContentType = .init(type),
            case .multipart(.formData(boundary: let boundary)) = type
        {
            guard let valid:MultipartForm = try? .init(splitting: body, on: boundary)
            else
            {
                return nil
            }

            form = valid
        }
        else
        {
            form = nil
        }

        if  let root:Int = path.indices.first,
            let post:AnyOperation = .post(
                root: path[root],
                rest: path[path.index(after: root)...],
                form: form)
        {
            self.init(operation: post, promise: promise())
        }
        else
        {
            return nil
        }
    }
}
