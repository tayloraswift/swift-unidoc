import SwiftinitPlugins
import UnidocDB

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
extension Swiftinit.LinterPlugin:Swiftinit.ServerPlugin
{
    func run(in context:Swiftinit.ServerPluginContext, with db:Swiftinit.DB) async throws
    {
        var linter:Swiftinit.Linter = .init(updating: self.status)
        try await linter.watch(db: db.unidoc, with: db.sessions)
    }
}
