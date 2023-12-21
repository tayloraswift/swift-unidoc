import GitHubAPI
import GitHubClient
import HTTPServer
import MongoDB
import UnidocDB
import UnixTime

protocol GitHubCrawler
{
    static
    var interval:Duration { get }

    var api:GitHubClient<GitHub.API> { get }

    func crawl(updating server:Swiftinit.ServerLoop,
        over connection:GitHubClient<GitHub.API>.Connection,
        with session:Mongo.Session) async throws
}
extension GitHubCrawler
{
    func run(alongside server:Swiftinit.ServerLoop) async throws
    {
        while true
        {
            async
            let cooldown:Void = Task.sleep(for: Self.interval)

            do
            {
                let session:Mongo.Session = try await .init(from: server.db.sessions)
                try await self.api.connect
                {
                    try await self.crawl(updating: server, over: $0, with: session)
                }
            }
            catch let error as any GitHubRateLimitError
            {
                try await Task.sleep(for: error.until - .now())
            }
            catch let error
            {
                Log[.warning] = "GitHub crawling error: \(error)"
                server.atomics.errorsCrawling.wrappingIncrement(ordering: .relaxed)
            }

            try await cooldown
        }
    }
}
