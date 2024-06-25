import HTTP
import HTTPServer
import MongoDB
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    /// Queues one or more editions for uplinking. The uplinking process itself is asynchronous.
    struct LinkerOperation:Sendable
    {
        let queue:Unidoc.DB.Snapshots.QueueAction
        let from:String?

        init(queue:Unidoc.DB.Snapshots.QueueAction, from:String? = nil)
        {
            self.queue = queue
            self.from = from
        }
    }
}
extension Unidoc.LinkerOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        try await session.update(database: server.db.unidoc.id, with: self.queue)
        return .redirect(.seeOther(self.from ?? "/admin"))
    }
}
