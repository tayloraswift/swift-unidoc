import HTTP
import MongoDB
import UnidocDB

extension Swiftinit
{
    protocol BlockingEndpoint:ProceduralEndpoint
    {
        func perform(on server:borrowing Server,
            payload:consuming [UInt8],
            session:Mongo.Session) async throws -> HTTP.ServerResponse
    }
}
extension Swiftinit.BlockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        request:Swiftinit.ServerLoop.Promise) async
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
