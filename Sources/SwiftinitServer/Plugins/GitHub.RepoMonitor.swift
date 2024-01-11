import BSON
import GitHubAPI
import GitHubClient
import HTTPServer
import MongoDB
import SemanticVersions
import UnidocDB
import UnidocRecords
import UnixTime

extension GitHub
{
    struct RepoMonitor:Sendable
    {
        var status:StatusPage

        init()
        {
            self.status = .init()
        }
    }
}
extension GitHub.RepoMonitor:GitHub.Crawler
{
    var interval:Duration { .seconds(30) }

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

            if  let crawled:BSON.Millisecond = package.crawled
            {
                self.status.lag = .milliseconds(now.value - crawled.value)
            }

            if  let repo:GitHub.Repo = response.repo
            {
                package.repo = try .github(repo, crawled: now)
            }
            else
            {
                package.repo = nil
                Log[.warning] = "(crawler) returned null for repo '\(package.symbol)'"
            }

            if  let days:Int64 = package.crawlingIntervalTargetDays
            {
                package.expires = .init(now.value + days * 86400 * 1000)
            }

            package.crawled = now

            if  case nil = try await db.packages.update(metadata: package, with: session)
            {
                //  Might happen if package database is dropped while crawling.
                continue
            }
            else
            {
                //  To MongoDB, all repo updates look like modifications, since the package
                //  record contains a timestamp.
                self.status.reposCrawled += 1
            }

            //  Import tags in chronological order. The last tag in the GraphQL response
            //  is the most recent.
            var prerelease:String? = nil
            var release:String? = nil

            for tag:GitHub.Tag in response.tags
            {
                guard
                let version:SemanticVersion = .init(refname: tag.name)
                else
                {
                    //  We don’t care about non-semver tags.
                    continue
                }

                switch try await db.unidoc.register(
                    package: package.id,
                    version: version,
                    refname: tag.name,
                    sha1: tag.hash,
                    with: session)
                {
                case (let edition, new: true):
                    self.status.tagsUpdated += 1

                    switch version
                    {
                    case .prerelease:   prerelease = edition.name
                    case .release:      release = edition.name
                    }

                    fallthrough

                case (_, new: false):
                    self.status.tagsCrawled += 1
                }
            }

            if  package.hidden
            {
                continue
            }

            if  let interesting:String = release ?? prerelease
            {
                let activity:UnidocDatabase.RepoFeed.Activity = .init(discovered: .now(),
                    package: package.symbol,
                    refname: interesting)

                try await db.repoFeed.push(activity, with: session)
            }
        }
    }

    mutating
    func log(error:consuming any Error)
    {
        self.status.error = error
    }
}
