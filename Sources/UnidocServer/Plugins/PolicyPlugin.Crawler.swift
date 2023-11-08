import Atomics
import HTTP
import HTTPClient
import HTTPServer
import IP

extension PolicyPlugin
{
    struct Crawler
    {
        private
        let googlebot:HTTP2Client
        private
        let bingbot:HTTP2Client

        init(
            googlebot:HTTP2Client,
            bingbot:HTTP2Client)
        {
            self.googlebot = googlebot
            self.bingbot = bingbot
        }
    }
}

extension PolicyPlugin.Crawler
{
    func run(
        updating policylist:ManagedAtomic<HTTP.Policylist>,
        counters:borrowing Server.Counters) async throws
    {
        while true
        {
            async
            let cooldown:Void = Task.sleep(for: .seconds(30 * 60))

            do
            {
                policylist.store(try await self.refresh(), ordering: .relaxed)
            }
            catch let error
            {
                Log[.warning] = "Whitelist fetch error: \(error)"
                counters.errorsCrawling.wrappingIncrement(ordering: .relaxed)
            }

            try await cooldown
        }
    }

    private
    func refresh() async throws -> HTTP.Policylist
    {
        var v4:IP.BlockTable<IP.V4, IP.Service> = [:]
        var v6:IP.BlockTable<IP.V6, IP.Service> = [:]
        try await self.googlebot.connect
        {
            let response:Response = try await $0.get(
                from: "/static/search/apis/ipranges/googlebot.json")

            v4.update(blocks: response.v4, with: .googlebot)
            v6.update(blocks: response.v6, with: .googlebot)
        }
        try await self.bingbot.connect
        {
            let response:Response = try await $0.get(
                from: "/toolbox/bingbot.json")

            v4.update(blocks: response.v4, with: .bingbot)
            v6.update(blocks: response.v6, with: .bingbot)
        }

        return .init(v4: v4, v6: v6)
    }
}
