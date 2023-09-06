import HTTPServer
import Media
import MD5
import Multiparts
import NIOCore
import NIOHTTP1
import UnidocPages
import UnidocQueries
import URI

extension Server
{
    struct Operation:Sendable
    {
        let endpoint:Endpoint
        let cookies:Request.Cookies

        init(endpoint:Endpoint, cookies:Request.Cookies)
        {
            self.endpoint = endpoint
            self.cookies = cookies
        }
    }
}
extension Server.Operation:HTTPServerOperation
{
    init?(get uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders)
    {
        guard let uri:URI = .init(uri)
        else
        {
            return nil
        }

        let path:[String] = uri.path.normalized(lowercase: true)

        let cookies:Server.Request.Cookies = .init(headers[canonicalForm: "cookie"])
        let tag:MD5? = headers.ifNoneMatch.first.flatMap(MD5.init(_:))

        if  let root:Int = path.indices.first,
            let get:Server.Endpoint = .get(
                root: path[root],
                rest: path[path.index(after: root)...],
                uri: uri,
                tag: tag)
        {
            self.init(endpoint: get, cookies: cookies)
        }
        else
        {
            //  Hilariously, we don’t have a home page yet. So we just redirect to the docs
            //  for the standard library.
            let get:Server.Endpoint = .stateful(Server.Endpoint.Pipeline<WideQuery>.init(
                explain: false,
                query: .init(
                    volume: .init(package: .swift, version: nil),
                    lookup: .init(stem: [])),
                uri: uri,
                tag: tag))

            self.init(endpoint: get, cookies: cookies)
        }
    }

    init?(post uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8])
    {
        guard let uri:URI = .init(uri)
        else
        {
            return nil
        }

        let path:[String] = uri.path.normalized(lowercase: true)

        let cookies:Server.Request.Cookies = .init(headers[canonicalForm: "cookie"])
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
            let post:Server.Endpoint = .post(
                root: path[root],
                rest: path[path.index(after: root)...],
                form: form)
        {
            self.init(endpoint: post, cookies: cookies)
        }
        else
        {
            return nil
        }
    }
}
