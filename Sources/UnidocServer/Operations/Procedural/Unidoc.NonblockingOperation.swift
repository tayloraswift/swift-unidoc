import HTTP
import Media
import MongoDB
import UnidocRender

extension Unidoc
{
    public
    protocol NonblockingOperation:ProceduralOperation
    {
        associatedtype Status:HTTP.ServerEndpoint<RenderFormat>

        func enqueue(on server:Server,
            payload:consuming [UInt8],
            session:Mongo.Session) async throws -> Status

        func perform(on server:Server,
            session:Mongo.Session,
            status:Status) async
    }
}
extension Unidoc.NonblockingOperation
{
    public
    func perform(on server:Unidoc.Server,
        payload:consuming [UInt8],
        request:Unidoc.Server.Promise) async
    {
        let session:Mongo.Session
        let status:Status
        do
        {
            session = try await .init(from: server.db.sessions)
            status = try await self.enqueue(on: server,
                payload: payload,
                session: session)
            request.resume(returning: try status.response(as: server.format))
        }
        catch let error
        {
            request.resume(rendering: error, as: server.format)
            return
        }

        await self.perform(on: server, session: session, status: status)
    }
}
