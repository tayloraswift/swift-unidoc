import NIOHPACK
import HTTPServer
import UnidocServer

extension Unidoc.Server:HTTP.Server
{
    public
    func get(
        request:HTTP.ServerRequest,
        headers:HPACKHeaders) async throws -> HTTP.ServerResponse
    {
        let request:Unidoc.ServerRequest = .init(
            headers: headers,
            client: .init(origin: request.origin),
            uri: request.uri)
        return try await self.get(request: request)
    }

    public
    func post(
        request:HTTP.ServerRequest,
        headers:HPACKHeaders,
        body:[UInt8]) async throws -> HTTP.ServerResponse
    {
        let request:Unidoc.ServerRequest = .init(
            headers: headers,
            client: .init(origin: request.origin),
            uri: request.uri)
        return try await self.post(request: request, body: body)
    }
}
