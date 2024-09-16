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
        let action:LinkerAction
        let scope:Edition?
        let back:String?

        init(action:Unidoc.LinkerAction, scope:Unidoc.Edition?, back:String? = nil)
        {
            self.action = action
            self.scope = scope
            self.back = back
        }
    }
}
extension Unidoc.LinkerOperation
{
    init(action:Unidoc.LinkerAction, form:Unidoc.LinkerForm)
    {
        self.init(action: action, scope: form.edition, back: form.back)
    }
}
extension Unidoc.LinkerOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        db:Unidoc.DB,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        if  let scope:Unidoc.Edition = self.scope
        {
            try await db.snapshots.queue(id: scope, for: self.action)
        }
        else
        {
            try await db.snapshots.queueAll(for: self.action)
        }

        return .redirect(.seeOther(self.back ?? "/admin"))
    }
}
