import HTTPClient
import HTTPServer
import IP

extension Swiftinit
{
    struct PolicyClient:Identifiable
    {
        private
        let http2:HTTP2Client
        private
        let path:String
        let id:IP.Service

        private
        init(http2:HTTP2Client, path:String, id:IP.Service)
        {
            self.http2 = http2
            self.path = path
            self.id = id
        }
    }
}
extension Swiftinit.PolicyClient
{
    static
    func bingbot(_ context:Swiftinit.ServerPluginContext) -> Self
    {
        .init(http2: .init(
                threads: context.threads,
                niossl: context.niossl,
                remote: "www.bing.com"),
            path: "/toolbox/bingbot.json",
            id: .bingbot)
    }

    static
    func googlebot(_ context:Swiftinit.ServerPluginContext) -> Self
    {
        .init(http2: .init(
                threads: context.threads,
                niossl: context.niossl,
                remote: "developers.google.com"),
            path: "/static/search/apis/ipranges/googlebot.json",
            id: .googlebot)
    }
}
extension Swiftinit.PolicyClient
{
    func update(
        v4:inout IP.BlockTable<IP.V4, IP.Service>,
        v6:inout IP.BlockTable<IP.V6, IP.Service>) async throws
    {
        try await self.http2.connect
        {
            let response:Response = try await $0.get(from: self.path)

            v4.update(blocks: response.v4, with: self.id)
            v6.update(blocks: response.v6, with: self.id)
        }
    }
}
