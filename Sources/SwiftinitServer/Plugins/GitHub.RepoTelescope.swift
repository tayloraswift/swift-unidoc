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
        var status:StatusPage

        init()
        {
            self.status = .init()
        }
    }
}
extension GitHub.RepoTelescope:GitHub.Crawler
{
    //  Picking something relatively prime to 30 seconds.
    var interval:Duration { .seconds(13) }

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
            created:\(created.year)-\(created.mm)-\(created.dd) \
            stars:>1
            """)

        let now:BSON.Millisecond = .now()

        window.expires = now
        window.crawled = now

        self.status.windowsCrawled += 1

        for repo:GitHub.Repo in discovered.repos
        {
            let symbol:Symbol.Package = "\(repo.owner.login).\(repo.name)"
            let repo:Unidoc.PackageRepo = try .github(repo, crawled: now)

            switch try await db.unidoc.index(
                package: symbol,
                repo: repo,
                mode: .automatic,
                with: session)
            {
            case (_, new: true):
                self.status.reposIndexed += 1
                fallthrough

            case (_, new: false):
                self.status.reposCrawled += 1
            }

        }

        try await db.crawlingWindows.push(window: window, with: session)
    }

    mutating
    func log(error:consuming any Error)
    {
        self.status.error = error
    }
}
