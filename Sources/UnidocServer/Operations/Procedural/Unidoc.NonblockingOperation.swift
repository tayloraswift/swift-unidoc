import HTTP
import Media
import MongoDB
import UnidocDB
import UnidocRender

extension Unidoc {
    public protocol NonblockingOperation: ProceduralOperation {
        associatedtype Status: HTTP.ServerEndpoint<RenderFormat>

        func enqueue(
            payload: consuming [UInt8],
            on server: Server,
            db: Unidoc.DB
        ) async throws -> Status

        func perform(status: Status, on server: Server, db: Unidoc.DB) async
    }
}
extension Unidoc.NonblockingOperation {
    public func serve(
        request: Unidoc.Server.Promise,
        with payload: [UInt8],
        from server: Unidoc.Server
    ) async {
        let status: Status
        let db: Unidoc.DB
        do {
            db = try await server.db.session()
            status = try await self.enqueue(payload: payload, on: server, db: db)
            request.resume(returning: try status.response(as: server.format()))
        } catch let error {
            server.logger.log(error: error)
            request.resume(rendering: error, as: server.format())
            return
        }

        await self.perform(status: status, on: server, db: db)
    }
}
