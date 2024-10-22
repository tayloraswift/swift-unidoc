import HTTP
import MongoDB
import UnidocDB

extension Unidoc
{
    public
    protocol BlockingOperation:ProceduralOperation
    {
        func perform(with payload:[UInt8],
            on server:Server,
            db:DB) async throws -> HTTP.ServerResponse
    }
}
extension Unidoc.BlockingOperation
{
    public
    func serve(request:Unidoc.Server.Promise,
        with payload:[UInt8],
        from server:Unidoc.Server) async
    {
        do
        {
            request.resume(returning: try await self.perform(with: payload,
                on: server,
                db: try await server.db.session()))
        }
        catch let error
        {
            request.resume(rendering: error, as: server.format())
        }
    }
}
