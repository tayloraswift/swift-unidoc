import HTTPClient
import HTTPServer
import IP
import UnidocServer

extension Swiftinit
{
    struct PolicyPlugin:Sendable
    {
        let status:AtomicPointer<StatusPage>

        init()
        {
            self.status = .init()
        }
    }
}
extension Swiftinit.PolicyPlugin:Identifiable
{
    var id:String { "policy" }
}
extension Swiftinit.PolicyPlugin:HTTP.ServerPolicy
{
    func load() -> IP.Policylist?
    {
        self.status.load()?.list
    }
}
extension Swiftinit.PolicyPlugin:Unidoc.ServerPlugin
{
    func run(in context:Unidoc.ServerPluginContext, with db:Unidoc.Database) async throws
    {
        let clients:[Swiftinit.PolicyClient] =
        [
            .googlebot(context),
            .bingbot(context),
        ]

        while true
        {
            async
            let cooldown:Void = Task.sleep(for: .seconds(30 * 60))

            do
            {
                var v4:IP.BlockTable<IP.V4, IP.Service> = [:]
                var v6:IP.BlockTable<IP.V6, IP.Service> = [:]

                let updated:ContinuousClock.Instant = .now
                for client:Swiftinit.PolicyClient in clients
                {
                    try await client.update(v4: &v4, v6: &v6)
                }

                let list:IP.Policylist = .init(v4: v4, v6: v6)

                self.status.replace(value: .init(updated: updated, list: list))
            }
            catch let error
            {
                Log[.warning] = "Whitelist fetch error: \(error)"
            }

            try await cooldown
        }
    }
}