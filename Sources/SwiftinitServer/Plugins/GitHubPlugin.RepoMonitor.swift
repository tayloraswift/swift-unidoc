import BSON
import GitHubAPI
import GitHubClient
import HTTPServer
import MongoDB
import SemanticVersions
import UnidocDB
import UnidocRecords
import UnixTime

extension GitHubPlugin
{
    struct Average
    {
        private(set)
        var total:Double
        private(set)
        var count:Int

        init()
        {
            self.total = 0
            self.count = 0
        }
    }
}
extension GitHubPlugin.Average
{
    mutating
    func insert(_ value:Double)
    {
        self.total += value
        self.count += 1
    }

    var value:Double?
    {
        self.count > 0 ? self.total / Double.init(self.count) : nil
    }
}
extension GitHubPlugin
{
    struct RepoMonitor
    {
        let api:GitHub.Client<GitHub.API>

        private
        let pat:String

        private
        var staleness:Average

        init(api:GitHub.Client<GitHub.API>, pat:String)
        {
            self.api = api
            self.pat = pat

            self.staleness = .init()
        }
    }
}




extension GitHubPlugin.RepoMonitor:GitHubCrawler
{
    static
    var interval:Duration { .seconds(30) }

    mutating
    func crawl(updating server:Swiftinit.ServerLoop,
        over connection:GitHub.Client<GitHub.API>.Connection,
        with session:Mongo.Session) async throws
    {
        let stale:[Unidoc.PackageMetadata] = try await server.db.packages.stalest(10,
            with: session)

        for var package:Unidoc.PackageMetadata in stale
        {
            guard
            let old:Unidoc.PackageRepo = package.repo
            else
            {
                fatalError("unreachable: repoless package was marked as stale!")
            }

            let origin:Unidoc.PackageRepo.GitHubOrigin
            switch old.origin
            {
            case .github(let github):   origin = github
            }

            let response:GitHubPlugin.RepoMonitorResponse = try await connection.crawl(
                owner: origin.owner,
                repo: origin.name,
                pat: self.pat)

            let now:BSON.Millisecond = .now()

            staleness:
            if  let crawled:BSON.Millisecond = package.crawled
            {
                //  Not entirely accurate (leap seconds!!!), but good enough for stats.
                self.staleness.insert(Double.init(now.value - crawled.value))

                guard
                let average:Double = self.staleness.value
                else
                {
                    break staleness
                }

                server.atomics.averagePackageStaleness.store(Int.init(average),
                    ordering: .relaxed)
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

            switch try await server.db.packages.update(metadata: package, with: session)
            {
            case nil:
                //  Might happen if package database is dropped while crawling.
                continue

            case _?:
                //  To MongoDB, all repo updates look like modifications, since the package
                //  record contains a timestamp.
                server.atomics.reposCrawled.wrappingIncrement(ordering: .relaxed)
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

                switch try await server.db.unidoc.register(
                    package: package.id,
                    version: version,
                    refname: tag.name,
                    sha1: tag.hash,
                    with: session)
                {
                case (let edition, new: true):
                    server.atomics.tagsUpdated.wrappingIncrement(ordering: .relaxed)

                    switch version
                    {
                    case .prerelease:   prerelease = edition.name
                    case .release:      release = edition.name
                    }

                    fallthrough

                case (_, new: false):
                    server.atomics.tagsCrawled.wrappingIncrement(ordering: .relaxed)
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

                try await server.db.repoFeed.push(activity, with: session)
            }
        }
    }
}
