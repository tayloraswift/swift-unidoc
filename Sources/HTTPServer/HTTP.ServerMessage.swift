import HTTP
import MD5
import Media
import NIOCore
import NIOHTTP1
import NIOHTTP2

extension HTTP
{
    struct ServerMessage<Headers>:Sendable where Headers:HeaderFormat
    {
        let status:UInt

        var headers:Headers
        var content:ByteBuffer?

        private
        init(origin:ServerOrigin, status:UInt, content:ByteBuffer? = nil)
        {
            self.status = status

            self.headers = .init(origin: origin, status: status)
            self.content = content
        }
    }
}
extension HTTP.ServerMessage
{
    init(origin:HTTP.ServerOrigin,
        response:HTTP.ServerResponse,
        using allocator:__shared ByteBufferAllocator)
    {
        switch response
        {
        case .resource(let resource, status: let status):
            self.init(origin: origin, status: status, copying: resource, using: allocator)

        case .redirect(let redirect, cookies: let cookies):
            self.init(origin: origin, redirect: redirect, cookies: cookies)
        }
    }

    static func error(origin:HTTP.ServerOrigin,
        string:String,
        using allocator:ByteBufferAllocator) -> Self
    {
        self.init(
            origin: origin,
            status: 500,
            copying: .init(
                headers: .init(),
                content: .init(
                    body: .string(string),
                    type: .text(.plain, charset: .utf8))),
            using: allocator)
    }
}
extension HTTP.ServerMessage
{
    private
    init(origin:HTTP.ServerOrigin,
        redirect:HTTP.Redirect,
        cookies:[(name:String, value:HTTP.CookieValue)])
    {
        self.init(origin: origin, status: redirect.status)

        switch redirect.target
        {
        case .domestic(let location):
            self.headers.add(name: "location", value: "\(origin)\(location)")

        case .external(let location):
            self.headers.add(name: "location", value: location)
            //  We should not set cookies on external redirects.
            return
        }

        for (name, value):(String, HTTP.CookieValue) in cookies
        {
            self.headers.add(name: "set-cookie",
                value: name.isEmpty ? value.string : "\(name)=\(value.string)")
        }
    }

    private
    init(origin:HTTP.ServerOrigin,
        status:UInt,
        copying resource:HTTP.Resource,
        using allocator:__shared ByteBufferAllocator)
    {
        if  let content:HTTP.Resource.Content = resource.content
        {
            let buffer:ByteBuffer
            let length:Int

            switch content.body
            {
            case .buffer(let bytes):
                length = bytes.readableBytes
                buffer = bytes

            case .binary(let bytes):
                length = bytes.count
                buffer = allocator.buffer(bytes: bytes)

            case .string(let string):
                length = string.utf8.count
                buffer = allocator.buffer(string: string)
            }

            self.init(origin: origin, status: status, content: buffer)

            self.headers.add(name: "content-length", value: "\(length)")
            self.headers.add(name: "content-type",   value: "\(content.type)")

            if  let encoding:MediaEncoding = content.encoding
            {
                self.headers.add(name: "content-encoding", value: "\(encoding)")
            }
        }
        else
        {
            self.init(origin: origin, status: 304)
        }

        if  let canonical:String = resource.headers.canonical
        {
            self.headers.add(name: "link", value: origin.link(canonical, rel: .canonical))
        }
        if  let count:Int = resource.headers.rateLimit.remaining
        {
            self.headers.add(name: "ratelimit-remaining", value: "\(count)")
        }
        if  let count:Int = resource.headers.rateLimit.limit
        {
            self.headers.add(name: "ratelimit-limit", value: "\(count)")
        }
        if  let reset:Int = resource.headers.rateLimit.reset
        {
            self.headers.add(name: "ratelimit-reset", value: "\(reset)")
        }
        if  let hash:MD5 = resource.hash
        {
            self.headers.add(name: "etag", value: "\"\(hash)\"")
        }

        self.headers.add(name: "access-control-allow-origin", value: "*")
    }
}
