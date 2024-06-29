import HTTP
import HTTPClient
import JSON
import NIOCore
import NIOHPACK

extension HTTP.Client2.Connection
{
    @inlinable public
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

        let response:HTTP.Client2.Facet = try await self.fetch(request)

        switch response.status
        {
        case 200?:
            let json:JSON = .init(utf8: response.body[...])
            return try json.decode()

        case let code:
            throw HTTP.StatusError.init(code: code)
        }
    }
}
