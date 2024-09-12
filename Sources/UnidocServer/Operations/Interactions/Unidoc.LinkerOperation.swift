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
        let queue:DB.Snapshots.QueueAction
        let back:String?

        init(queue:DB.Snapshots.QueueAction, back:String? = nil)
        {
            self.queue = queue
            self.back = back
        }
    }
}
extension Unidoc.LinkerOperation
{
    init(action:Unidoc.LinkerAction, form:Unidoc.LinkerForm)
    {
        self.init(queue: .one(form.edition, action: action), back: form.back)
    }
}
extension Unidoc.LinkerOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        db:Unidoc.DB,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        try await db.update(with: self.queue)
        return .redirect(.seeOther(self.back ?? "/admin"))
    }
}
