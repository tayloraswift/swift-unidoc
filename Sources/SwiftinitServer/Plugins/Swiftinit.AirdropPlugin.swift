import SwiftinitPlugins
import UnidocDB

extension Swiftinit
{
    struct AirdropPlugin:Sendable
    {
        let status:AtomicPointer<Unidoc.CollectionEventsPage<Airdrop>>

        init()
        {
            self.status = .init()
        }
    }
}
extension Swiftinit.AirdropPlugin:Identifiable
{
    var id:String { "airdrop" }
}
extension Swiftinit.AirdropPlugin:Swiftinit.ServerPlugin
{
    func run(in context:Swiftinit.ServerPluginContext, with db:Swiftinit.DB) async throws
    {
        var airdrop:Swiftinit.Airdrop = .init(updating: self.status, policy: db.policy)
        try await airdrop.watch(db: db.unidoc, with: db.sessions)
    }
}
