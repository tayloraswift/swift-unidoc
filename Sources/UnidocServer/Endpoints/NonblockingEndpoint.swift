import HTTP
import Media
import MongoDB
import UnidocPages

protocol NonblockingEndpoint:ProceduralEndpoint
{
    associatedtype Status:HTTP.ServerResponseFactory<Unidoc.RenderFormat>

    func enqueue(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        session:Mongo.Session) async throws -> Status

    func perform(on server:borrowing Swiftinit.Server,
        session:Mongo.Session,
        status:Status) async
}
extension NonblockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        request:CheckedContinuation<HTTP.ServerResponse, any Error>) async
    {
        let session:Mongo.Session
        let status:Status
        do
        {
            session = try await .init(from: server.db.sessions)
            status = try await self.enqueue(on: server,
                payload: payload,
                session: session)
            request.resume(returning: try status.response(as: .init(assets: server.assets)))
        }
        catch
        {
            request.resume(throwing: error)
            return
        }

        await self.perform(on: server, session: session, status: status)
    }
}
