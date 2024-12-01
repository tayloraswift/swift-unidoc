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
        init(_ status:UInt, binding:Origin, content:ByteBuffer? = nil)
        {
            self.status = status

            self.headers = .init(origin: binding, status: status)
            self.content = content
        }
    }
}
extension HTTP.ServerMessage
{
    init(
        payload:HTTP.ServerResponse,
        binding:HTTP.Origin,
        using allocator:__shared ByteBufferAllocator)
    {
        switch payload
        {
        case .resource(let resource, status: let status):
            self.init(status, copying: resource, binding: binding, using: allocator)

        case .redirect(let redirect, cookies: let cookies):
            self.init(redirect: redirect, binding: binding, cookies: cookies)
        }
    }

    static func error(
        message:String,
        binding:HTTP.Origin,
        using allocator:ByteBufferAllocator) -> Self
    {
        self.init(500,
            copying: .init(
                headers: .init(),
                content: .init(
                    body: .string(message),
                    type: .text(.plain, charset: .utf8))),
            binding: binding,
            using: allocator)
    }
}
extension HTTP.ServerMessage
{
    private
    init(
        redirect:HTTP.Redirect,
        binding:HTTP.Origin,
        cookies:[(name:String, value:HTTP.CookieValue)])
    {
        self.init(redirect.status, binding: binding)

        switch redirect.target
        {
        case .domestic(let location):
            self.headers.add(name: "location", value: "\(binding)\(location)")

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
    init(_ status:UInt,
        copying resource:HTTP.Resource,
        binding:HTTP.Origin,
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

            self.init(status, binding: binding, content: buffer)

            self.headers.add(name: "content-length", value: "\(length)")
            self.headers.add(name: "content-type",   value: "\(content.type)")

            if  let encoding:MediaEncoding = content.encoding
            {
                self.headers.add(name: "content-encoding", value: "\(encoding)")
            }
        }
        else
        {
            self.init(304, binding: binding)
        }

        if  let canonical:String = resource.headers.canonical
        {
            self.headers.add(name: "link", value: binding.link(canonical, rel: .canonical))
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
