import MongoDB
import SwiftinitPlugins
import UnidocDB

extension Swiftinit
{
    struct LinkerPlugin:Sendable
    {
        let status:AtomicPointer<StatusPage>

        init()
        {
            self.status = .init()
        }
    }
}
extension Swiftinit.LinkerPlugin:Identifiable
{
    var id:String { "linker" }
}
extension Swiftinit.LinkerPlugin:Swiftinit.ServerPlugin
{
    func run(in _:Swiftinit.ServerPluginContext, with db:Swiftinit.DB) async throws
    {
        var linker:Swiftinit.Linker = .init(updating: self.status)
        try await linker.watch(db)
    }
}
