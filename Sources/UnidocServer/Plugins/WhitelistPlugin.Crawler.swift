import HTTP
import HTTPClient
import HTTPServer
import IP

extension WhitelistPlugin
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

extension WhitelistPlugin.Crawler
{
    func run(counters:borrowing Server.Counters) async throws
    {
        while true
        {
            async
            let cooldown:Void = Task.sleep(for: .seconds(30 * 60))

            do
            {
                try await self.refresh()
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
    func refresh() async throws -> IP.Table<HTTP.KnownPeer>
    {
        var whitelist:IP.Table<HTTP.KnownPeer> = [:]
        try await self.googlebot.connect
        {
            let response:Response = try await $0.get(
                from: "/static/search/apis/ipranges/googlebot.json")

            for prefix:IP.Block<IP.V6> in response.prefixes
            {
                whitelist[prefix] = .googlebot
            }
        }
        try await self.bingbot.connect
        {
            let response:Response = try await $0.get(
                from: "/toolbox/bingbot.json")

            for prefix:IP.Block<IP.V6> in response.prefixes
            {
                whitelist[prefix] = .bingbot
            }
        }
        return whitelist
    }
}
