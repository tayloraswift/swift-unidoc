import HTTP
import Media
import MD5
import NIOCore
import NIOHTTP1
import NIOHTTP2

extension HTTP
{
    struct ServerMessage<Authority, Headers>
        where Authority:ServerAuthority, Headers:HTTPHeaderFormat
    {
        let status:UInt

        var headers:Headers
        var content:ByteBuffer?

        private
        init(_ status:UInt, content:ByteBuffer? = nil)
        {
            self.status = status

            self.headers = .init(authority: Authority.self, status: status)
            self.content = content
        }
    }
}
extension HTTP.ServerMessage
{
    init(authority _:Authority.Type = Authority.self,
        response:ServerResponse,
        using allocator:__shared ByteBufferAllocator)
    {
        switch response
        {
        case .ok(let resource):
            self.init(200, copying: resource, using: allocator)

        case .multiple(let resource):
            self.init(300, copying: resource, using: allocator)

        case .redirect(let redirect, cookies: let cookies):
            self.init(redirect: redirect, cookies: cookies)

        case .badRequest(let resource):
            self.init(400, copying: resource, using: allocator)

        case .unauthorized(let resource):
            self.init(401, copying: resource, using: allocator)

        case .forbidden(let resource):
            self.init(403, copying: resource, using: allocator)

        case .notFound(let resource):
            self.init(404, copying: resource, using: allocator)

        case .conflict(let resource):
            self.init(409, copying: resource, using: allocator)

        case .gone(let resource):
            self.init(410, copying: resource, using: allocator)

        case .error(let resource):
            self.init(500, copying: resource, using: allocator)

        case .unavailable(let resource):
            self.init(503, copying: resource, using: allocator)
        }
    }

    init(redacting error:any Error, using allocator:__shared ByteBufferAllocator)
    {
        self.init(500,
            copying: .init(
                headers: .init(),
                content: .string(Authority.redact(error: error)),
                type: .text(.plain, charset: .utf8)),
            using: allocator)
    }
}
extension HTTP.ServerMessage
{
    private
    init(redirect:HTTP.Redirect, cookies:[HTTP.Cookie])
    {
        switch redirect
        {
        case .temporary: self.init(307)
        case .permanent: self.init(308)
        }

        self.headers.add(name: "location", value: Authority.url(redirect.location))

        for cookie:HTTP.Cookie in cookies
        {
            self.headers.add(name: "set-cookie",
                value: "\(cookie); Secure; HttpOnly; SameSite = Lax; Path = /")
        }
    }

    private
    init(_ status:UInt,
        copying resource:ServerResource,
        using allocator:__shared ByteBufferAllocator)
    {
        let buffer:ByteBuffer?
        let length:Int
        switch resource.content
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

        case .length(let bytes):
            length = bytes
            buffer = nil
        }

        if  let buffer:ByteBuffer
        {
            self.init(status, content: buffer)
        }
        else
        {
            self.init(304)
        }

        if  let canonical:String = resource.headers.canonical
        {
            self.headers.add(name: "link", value: Authority.link(canonical, rel: .canonical))
        }
        if  let hash:MD5 = resource.hash
        {
            self.headers.add(name: "etag", value: "\"\(hash)\"")
        }

        self.headers.add(name: "content-length", value: "\(length)")
        self.headers.add(name: "content-type",   value: "\(resource.type)")
    }
}
