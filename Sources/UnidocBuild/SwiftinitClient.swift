import HTTPClient
import JSON

@frozen public
struct SwiftinitClient
{
    @usableFromInline internal
    let http2:HTTP2Client
    @usableFromInline internal
    let cookie:String

    @inlinable public
    init(http2:HTTP2Client, cookie:String)
    {
        self.http2 = http2
        self.cookie = cookie
    }
}
extension SwiftinitClient
{
    @inlinable public
    func connect<T>(port:Int, with body:(Connection) async throws -> T) async throws -> T
    {
        try await self.http2.connect(port: port)
        {
            try await body(Connection.init(http2: $0,
                cookie: self.cookie,
                remote: self.http2.remote))
        }
    }
}
extension SwiftinitClient
{
    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        port:Int,
        from endpoint:String) async throws -> Response where Response:JSONDecodable
    {
        try await self.connect(port: port) { try await $0.get(from: endpoint) }
    }
}
