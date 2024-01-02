import GitHubAPI
import GitHubClient
import MongoDB
import SwiftinitPlugins
import UnixTime

extension GitHub
{
    struct CrawlerPlugin<Crawler>:Identifiable, Sendable where Crawler:GitHub.Crawler
    {
        private
        let api:GitHub.API<String>
        let id:String
        let status:AtomicPointer<Crawler.StatusPage>

        init(api:GitHub.API<String>, id:String)
        {
            self.api = api
            self.id = id
            self.status = .init()
        }
    }
}
extension GitHub.CrawlerPlugin:Swiftinit.ServerPlugin
{
    func run(in context:Swiftinit.ServerPluginContext, with db:Swiftinit.DB) async throws
    {
        let github:GitHub.Client<GitHub.API<String>> = .graphql(api: self.api,
            threads: context.threads,
            niossl: context.niossl)

        var crawler:Crawler = .init()

        while true
        {
            let interval:Duration = crawler.interval

            async
            let cooldown:Void = Task.sleep(for: interval)

            do
            {
                let session:Mongo.Session = try await .init(from: db.sessions)
                try await github.connect
                {
                    try await crawler.crawl(updating: db, over: $0, with: session)
                }
                self.status.replace(value: crawler.status)
            }
            catch let error as any GitHub.RateLimitError
            {
                self.status.replace(value: crawler.status)
                try await Task.sleep(for: error.until - .now())
            }
            catch let error
            {
                crawler.log(error: error)
                self.status.replace(value: crawler.status)
            }

            try await cooldown
        }
    }
}
