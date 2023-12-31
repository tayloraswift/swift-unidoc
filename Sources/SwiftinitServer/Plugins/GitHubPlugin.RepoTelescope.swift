import GitHubAPI
import GitHubClient
import HTTPServer
import MongoDB
import Symbols
import UnidocDB
import UnidocRecords
import UnixTime

extension GitHubPlugin
{
    struct RepoTelescope
    {
        let api:GitHub.Client<GitHub.API>

        private
        let pat:String

        init(api:GitHub.Client<GitHub.API>, pat:String)
        {
            self.api = api
            self.pat = pat
        }
    }
}
extension GitHubPlugin.RepoTelescope:GitHubCrawler
{
    //  Picking something relatively prime to 30 seconds.
    static
    var interval:Duration { .seconds(13) }

    func crawl(updating server:Swiftinit.ServerLoop,
        over connection:GitHub.Client<GitHub.API>.Connection,
        with session:Mongo.Session) async throws
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)

        guard
        var window:Unidoc.CrawlingWindow = try await server.db.crawlingWindows.pull(
            with: session)
        else
        {
            // Log[.debug] = "Skipping telescope crawl: no windows left to crawl."
            return
        }

        let created:UnixInstant = .millisecond(window.id.value)

        guard
        let created:Timestamp.Date = created.timestamp?.date
        else
        {
            Log[.error] = "Skipping telescope crawl: invalid window timestamp!"
            return
        }

        let discovered:GitHubPlugin.RepoTelescopeResponse = try await connection.search(
            repos: """
            language:swift \
            created:\(created.year)-\(created.mm)-\(created.dd) \
            stars:>1
            """,
            pat: self.pat)

        window.expires = .now()
        window.crawled = window.expires

        for repo:GitHub.Repo in discovered.repos
        {
            let symbol:Symbol.Package = "\(repo.owner.login).\(repo.name)"
            switch try await server.db.unidoc.index(package: symbol,
                repo: try .github(repo),
                mode: .automatic,
                with: session)
            {
            case (let package, new: false):
                continue
                // Log[.debug] = "telescope: '\(package.symbol)' has already been discovered"

            case (let package, new: true):
                Log[.debug] = "telescope: '\(package.symbol)' added (created: \(repo.created))"
            }
        }

        try await server.db.crawlingWindows.push(window: window, with: session)
    }
}
