import BSON
import GitHubAPI
import GitHubClient
import HTTPServer
import MongoDB
import Symbols
import UnidocDB
import UnidocRecords
import UnixTime

extension GitHub
{
    struct RepoTelescope:Sendable
    {
        private
        var windowsCrawled:Int
        private
        var reposCrawled:Int
        private
        var reposIndexed:Int
        private
        var buffer:Swiftinit.EventBuffer<any Swiftinit.ServerPluginEvent>

        var error:(any Error)?

        init()
        {
            self.windowsCrawled = 0
            self.reposCrawled = 0
            self.reposIndexed = 0
            self.buffer = .init(minimumCapacity: 100)
            self.error = nil
        }
    }
}
extension GitHub.RepoTelescope:GitHub.Crawler
{
    //  Picking something relatively prime to 30 seconds.
    var interval:Duration { .seconds(13) }

    var status:StatusPage
    {
        .init(error: self.error,
            windowsCrawled: self.windowsCrawled,
            reposCrawled: self.reposCrawled,
            reposIndexed: self.reposIndexed,
            buffer: self.buffer)
    }

    mutating
    func crawl(updating db:Swiftinit.DB,
        over connection:GitHub.Client<GitHub.API<String>>.Connection,
        with session:Mongo.Session) async throws
    {
        let session:Mongo.Session = try await .init(from: db.sessions)

        guard
        var window:Unidoc.CrawlingWindow = try await db.crawlingWindows.pull(
            with: session)
        else
        {
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

        let discovered:GitHub.RepoTelescopeResponse = try await connection.search(
            repos: """
            language:swift \
            archived:false \
            created:\(created.year)-\(created.mm)-\(created.dd) \
            stars:>1
            """)

        let now:BSON.Millisecond = .now()

        window.expires = now
        window.crawled = now

        self.windowsCrawled += 1

        for repo:GitHub.Repo in discovered.repos
        {
            let symbol:Symbol.Package = "\(repo.owner.login).\(repo.name)"

            switch try await db.unidoc.index(
                package: symbol,
                repo: try .github(repo, crawled: now),
                mode: .automatic,
                with: session)
            {
            case (_, new: true):
                self.buffer.push(
                    event: GitHub.RepoTelescope.DiscoveryEvent.init(package: symbol))
                self.reposIndexed += 1
                fallthrough

            case (_, new: false):
                self.reposCrawled += 1
            }

        }

        try await db.crawlingWindows.push(window: window, with: session)
    }
}
