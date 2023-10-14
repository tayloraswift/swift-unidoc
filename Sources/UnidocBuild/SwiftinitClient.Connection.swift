import BSON
import HTTPClient
import JSON
import Media
import NIOCore
import NIOHPACK
import URI

extension SwiftinitClient
{
    @frozen public
    struct Connection
    {
        @usableFromInline internal
        let http2:HTTP2Client.Connection
        @usableFromInline internal
        let cookie:String
        @usableFromInline internal
        let remote:String

        @inlinable internal
        init(http2:HTTP2Client.Connection, cookie:String, remote:String)
        {
            self.http2 = http2
            self.cookie = cookie
            self.remote = remote
        }
    }
}
extension SwiftinitClient.Connection
{
    @inlinable internal
    func headers(_ method:String, _ endpoint:String) -> HPACKHeaders
    {
        [
            ":method": method,
            ":scheme": "https",
            ":authority": self.remote,
            ":path": endpoint,

            "user-agent": "UnidocBuild",
            "accept": "application/json",
            "cookie": "__Host-session=\(self.cookie)",
        ]
    }
}
extension SwiftinitClient.Connection
{
    @discardableResult
    @inlinable public
    func post(urlencoded:consuming String, to endpoint:String) async throws -> [ByteBuffer]
    {
        try await self.fetch(endpoint, method: "POST",
            body: self.http2.buffer(string: urlencoded),
            type: .application(.x_www_form_urlencoded))
    }

    @discardableResult
    @inlinable public
    func put(bson:consuming BSON.Document, to endpoint:String) async throws -> [ByteBuffer]
    {
        try await self.fetch(endpoint, method: "PUT",
            body: self.http2.buffer(bytes: (consume bson).bytes),
            type: .application(.bson))
    }

    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String) async throws -> Response where Response:JSONDecodable
    {
        var json:JSON = .init(utf8: [])

        for buffer:ByteBuffer in try await self.fetch(endpoint, method: "GET")
        {
            json.utf8 += buffer.readableBytesView
        }

        return try json.decode()
    }
}
extension SwiftinitClient.Connection
{
    @inlinable internal
    func fetch(_ endpoint:String,
        method:String,
        body:ByteBuffer? = nil,
        type:MediaType? = nil) async throws -> [ByteBuffer]
    {
        var endpoint:String = endpoint
        var status:UInt? = nil

        following:
        for _:Int in 0 ... 1
        {
            var headers:HPACKHeaders = self.headers(method, endpoint)
            if  let type:MediaType
            {
                headers.add(name: "content-type", value: "\(type)")
            }

            let response:HTTP2Client.Facet = try await self.http2.fetch(.init(
                headers: headers,
                body: body))

            switch response.status
            {
            case 200?:
                return response.buffers

            case 301?:
                if  let location:String = response.headers?["location"].first
                {
                    endpoint = String.init(location.trimmingPrefix("https://\(self.remote)"))
                    continue following
                }
            case _:
                break
            }

            status = response.status
            break following
        }

        throw SwiftinitClient.StatusError.init(code: status)
    }
}
