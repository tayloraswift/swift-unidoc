import HTTP
import HTTPServer
import MongoDB
import Unidoc
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    /// Queues one or more editions for uplinking. The uplinking process itself is asynchronous.
    struct GraphActionEndpoint:Sendable
    {
        let queue:Unidoc.DB.Snapshots.QueueAction
        let uri:String?

        init(queue:Unidoc.DB.Snapshots.QueueAction, uri:String? = nil)
        {
            self.queue = queue
            self.uri = uri
        }
    }
}
extension Swiftinit.GraphActionEndpoint:Swiftinit.AdministrativeEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        try await session.update(database: server.db.unidoc.id, with: self.queue)
        return .redirect(.seeOther(self.uri ?? "/admin"))
    }
}
