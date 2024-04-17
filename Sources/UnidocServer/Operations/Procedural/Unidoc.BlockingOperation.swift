import HTTP
import MongoDB
import UnidocDB

extension Unidoc
{
    public
    protocol BlockingOperation:ProceduralOperation
    {
        func perform(on server:borrowing Server,
            payload:consuming [UInt8],
            session:Mongo.Session) async throws -> HTTP.ServerResponse
    }
}
extension Unidoc.BlockingOperation
{
    public
    func perform(on server:borrowing Unidoc.Server,
        payload:consuming [UInt8],
        request:Unidoc.ServerLoop.Promise) async
    {
        do
        {
            let session:Mongo.Session = try await .init(from: server.db.sessions)
            request.resume(returning: try await self.perform(on: server,
                payload: payload,
                session: session))
        }
        catch
        {
            request.resume(rendering: error, as: server.format)
        }
    }
}
