import UnidocDB
import UnidocServer

extension Swiftinit
{
    struct LinterPlugin:Sendable
    {
        let status:AtomicPointer<Unidoc.CollectionEventsPage<Linter>>

        init()
        {
            self.status = .init()
        }
    }
}
extension Swiftinit.LinterPlugin:Identifiable
{
    var id:String { "linter" }
}
extension Swiftinit.LinterPlugin:Unidoc.ServerPlugin
{
    func run(in context:Unidoc.ServerPluginContext, with db:Unidoc.Database) async throws
    {
        var linter:Swiftinit.Linter = .init(updating: self.status)
        try await linter.watch(db: db.unidoc, with: db.sessions)
    }
}
