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
        let update:Update
        let scope:Edition?
        let back:String?

        init(update:Update, scope:Unidoc.Edition?, back:String? = nil)
        {
            self.update = update
            self.scope = scope
            self.back = back
        }
    }
}
extension Unidoc.LinkerOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        db:Unidoc.DB,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        switch (self.scope, self.update)
        {
        case (nil, .action(let action)):
            try await db.snapshots.queueAll(for: action)

        case (let scope?, .action(let action)):
            try await db.snapshots.queue(id: scope, for: action)

        case (let scope?, .vintage(let vintage)):
            try await db.snapshots.mark(id: scope, vintage: vintage)

        default:
            return nil
        }

        return .redirect(.seeOther(self.back ?? "/admin"))
    }
}
