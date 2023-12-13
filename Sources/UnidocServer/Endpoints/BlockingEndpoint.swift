import HTTP
import MongoDB
import UnidocDB

protocol BlockingEndpoint:ProceduralEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        session:Mongo.Session) async throws -> HTTP.ServerResponse
}
extension BlockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        request:CheckedContinuation<HTTP.ServerResponse, any Error>) async
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
            request.resume(throwing: error)
        }
    }
}
