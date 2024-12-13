import NIOHPACK
import HTTPServer
import UnidocServer

extension Unidoc.Server:HTTP.Server
{
    public
    func accept(request:HTTP.ServerRequest,
        method:HTTP.ServerMethod) async throws -> HTTP.ServerResponse
    {
        switch method
        {
        case .delete:
            let request:Unidoc.ServerRequest = .init(metadata: request, client: nil)
            return try await self.delete(request: request)

        case .get, .head:
            let request:Unidoc.ServerRequest = .init(metadata: request, client: nil)
            return try await self.get(request: request)

        case .post(let body):
            let request:Unidoc.ServerRequest = .init(metadata: request, client: nil)
            return try await self.post(request: request, body: body)

        case .put(let body):
            //  We do not do any client inference here, as `PUT` requests are pre-checked.
            return await self.put(request: request, body: body)
        }
    }
}
