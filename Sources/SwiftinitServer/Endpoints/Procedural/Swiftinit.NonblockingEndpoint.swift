import HTTP
import Media
import MongoDB
import SwiftinitPages

extension Swiftinit
{
    protocol NonblockingEndpoint:ProceduralEndpoint
    {
        associatedtype Status:HTTP.ServerEndpoint<RenderFormat>

        func enqueue(on server:borrowing Server,
            payload:consuming [UInt8],
            session:Mongo.Session) async throws -> Status

        func perform(on server:borrowing Server,
            session:Mongo.Session,
            status:Status) async
    }
}
extension Swiftinit.NonblockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        request:Swiftinit.ServerLoop.Promise) async
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
