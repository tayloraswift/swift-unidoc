import HTTP
import HTTPClient
import JSON
import NIOCore
import NIOHPACK

extension HTTP2Client.Connection
{
    func get<Response>(_:Response.Type = Response.self,
        from path:String,
        as agent:String = "Unidoc") async throws -> Response
        where Response:JSONDecodable
    {
        let request:HPACKHeaders =
        [
            ":method": "GET",
            ":scheme": "https",
            ":authority": self.remote,
            ":path": path,

            "user-agent": agent,
            "accept": "*/*",
        ]

        print(request)

        let response:HTTP2Client.Facet = try await self.fetch(request)

        switch response.status
        {
        case 200?:
            var json:JSON = .init(utf8: [])
            for buffer:ByteBuffer in response.buffers
            {
                buffer.withUnsafeReadableBytes { json.utf8 += $0 }
            }
            return try json.decode()

        case let code:
            throw HTTP.StatusError.init(code: code)
        }
    }
}
