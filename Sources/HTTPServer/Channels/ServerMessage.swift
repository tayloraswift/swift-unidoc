import HTTP
import Media
import MD5
import NIOCore
import NIOHTTP1

struct ServerMessage<Authority> where Authority:ServerAuthority
{
    let headers:HTTPHeaders
    let status:HTTPResponseStatus
    let body:ByteBuffer?

    private
    init(headers:HTTPHeaders, status:HTTPResponseStatus, body:ByteBuffer? = nil)
    {
        self.headers = headers
        self.status = status
        self.body = body
    }
}
extension ServerMessage
{
    init(response:ServerResponse, using allocator:__shared ByteBufferAllocator)
    {
        switch response
        {
        case .ok(let resource):
            self.init(resource: resource, using: allocator, as: .ok)

        case .multiple(let resource):
            self.init(resource: resource, using: allocator, as: .multipleChoices)

        case .redirect(let redirect, cookies: let cookies):
            self.init(redirect: redirect, cookies: cookies)

        case .badRequest(let resource):
            self.init(resource: resource, using: allocator, as: .badRequest)

        case .unauthorized(let resource):
            self.init(resource: resource, using: allocator, as: .unauthorized)

        case .forbidden(let resource):
            self.init(resource: resource, using: allocator, as: .forbidden)

        case .notFound(let resource):
            self.init(resource: resource, using: allocator, as: .notFound)

        case .conflict(let resource):
            self.init(resource: resource, using: allocator, as: .conflict)

        case .gone(let resource):
            self.init(resource: resource, using: allocator, as: .gone)

        case .error(let resource):
            self.init(resource: resource, using: allocator, as: .internalServerError)

        case .unavailable(let resource):
            self.init(resource: resource, using: allocator, as: .serviceUnavailable)
        }
    }

    init(redacting error:any Error, using allocator:__shared ByteBufferAllocator)
    {
        self.init(resource: .init(
                headers: .init(),
                content: .string(Authority.redact(error: error)),
                type: .text(.plain, charset: .utf8)),
            using: allocator,
            as: .internalServerError)
    }
}
extension ServerMessage
{
    private
    init(redirect:ServerRedirect, cookies:[Cookie])
    {
        var headers:HTTPHeaders = .init()

        headers.add(name: "host", value: Authority.domain)
        headers.add(name: "location", value: Authority.url(redirect.location))

        for cookie:Cookie in cookies
        {
            headers.add(name: "set-cookie",
                value: "\(cookie); Secure; HttpOnly; SameSite = Lax; Path = /")
        }

        let status:HTTPResponseStatus
        switch redirect
        {
        case .permanent: status = .permanentRedirect
        case .temporary: status = .temporaryRedirect
        }

        self.init(headers: headers, status: status, body: nil)
    }

    private
    init(resource:ServerResource,
        using allocator:__shared ByteBufferAllocator,
        as status:HTTPResponseStatus)
    {
        var headers:HTTPHeaders = .init()

        headers.add(name: "host", value: Authority.domain)

        if  let canonical:String = resource.headers.canonical
        {
            headers.add(name: "link", value: Authority.link(canonical, rel: .canonical))
        }
        if  let hash:MD5 = resource.hash
        {
            headers.add(name: "etag", value: "\"\(hash)\"")
        }

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

        headers.add(name: "content-length", value: "\(length)")
        headers.add(name: "content-type",   value: "\(resource.type)")

        if  let buffer:ByteBuffer
        {
            self.init(headers: headers, status: status, body: buffer)
        }
        else
        {
            self.init(headers: headers, status: .notModified)
        }
    }
}
extension ServerMessage
{
    init(status:HTTPResponseStatus)
    {
        let buffer:ByteBuffer = .init(string: "\(status.code) (\(status.reasonPhrase))")
        var headers:HTTPHeaders = .init()

        headers.add(name: "host", value: Authority.domain)
        headers.add(name: "content-length", value: "\(buffer.readableBytes)")
        headers.add(name: "content-type",   value: "\(MediaType.text(.plain, charset: .utf8))")

        self.init(headers: headers, status: status, body: buffer)
    }
}
