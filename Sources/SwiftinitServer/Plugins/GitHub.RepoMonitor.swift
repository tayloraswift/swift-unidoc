import BSON
import Durations
import GitHubAPI
import GitHubClient
import HTML
import HTTPServer
import MongoDB
import SemanticVersions
import UnidocDB
import UnidocRecords
import UnixTime

extension GitHub
{
    struct RepoMonitor
    {
        private
        var reposCrawled:Int
        private
        var tagsCrawled:Int
        private
        var tagsUpdated:Int
        private
        var buffer:Swiftinit.EventBuffer<any Swiftinit.ServerPluginEvent>

        var error:(any Error)?

        init()
        {
            self.reposCrawled = 0
            self.tagsCrawled = 0
            self.tagsUpdated = 0
            self.buffer = .init(minimumCapacity: 100)
            self.error = nil
        }
    }
}
extension GitHub.RepoMonitor:GitHub.Crawler
{
    var interval:Duration { .seconds(30) }
    var status:StatusPage
    {
        .init(error: self.error,
            reposCrawled: self.reposCrawled,
            tagsCrawled: self.tagsCrawled,
            tagsUpdated: self.tagsUpdated,
            buffer: self.buffer)
    }

    mutating
    func crawl(updating db:Swiftinit.DB,
        over connection:GitHub.Client<GitHub.API<String>>.Connection,
        with session:Mongo.Session) async throws
    {
        let stale:[Unidoc.PackageMetadata] = try await db.packages.stalest(10,
            with: session)

        for var package:Unidoc.PackageMetadata in stale
        {
            guard
            let old:Unidoc.PackageRepo = package.repo
            else
            {
                fatalError("unreachable: repoless package was marked as stale!")
            }

            let origin:Unidoc.GitHubOrigin
            switch old.origin
            {
            case .github(let github):   origin = github
            }

            let response:GitHub.RepoMonitorResponse = try await connection.crawl(
                owner: origin.owner,
                repo: origin.name)

            let now:BSON.Millisecond = .now()

            self.reposCrawled += 1
            self.buffer.push(event: CrawlingEvent.init(package: package.symbol,
                sinceExpected: old.expires?.duration(to: now),
                sinceActual: old.crawled.duration(to: now),
                repo: response.repo))

            if  let repo:GitHub.Repo = response.repo
            {
                package.fetched(repo: try .github(repo, crawled: now))
            }
            else
            {
                package.repo = nil
            }

            if  case nil = try await db.packages.update(package: package.id,
                    repo: package.repo,
                    with: session)
            {
                //  Might happen if package database is dropped while crawling.
                continue
            }

            //  Import tags in chronological order. The last tag in the GraphQL response
            //  is the most recent.
            var indexed:IndexTagsEvent = .init(package: package.symbol)
            for tag:GitHub.Tag in response.tags
            {
                guard
                let version:SemanticVersion = .init(refname: tag.name)
                else
                {
                    //  We don’t care about non-semver tags.
                    continue
                }

                switch try await db.unidoc.index(
                    package: package.id,
                    version: version,
                    name: tag.name,
                    sha1: tag.hash,
                    with: session)
                {
                case (let edition, new: true):
                    indexed.updated += 1

                    switch version
                    {
                    case .prerelease:   indexed.prerelease = edition
                    case .release:      indexed.release = edition
                    }

                    fallthrough

                case (_, new: false):
                    indexed.crawled += 1
                }
            }

            self.tagsCrawled += indexed.crawled
            self.tagsUpdated += indexed.updated

            if  indexed.crawled > 0
            {
                self.buffer.push(event: indexed)
            }

            if  package.hidden
            {
                continue
            }

            if  let interesting:String = (indexed.release ?? indexed.prerelease)?.name
            {
                let activity:Unidoc.DB.RepoFeed.Activity = .init(discovered: now,
                    package: package.symbol,
                    refname: interesting)

                try await db.repoFeed.push(activity, with: session)
            }
        }
    }
}
