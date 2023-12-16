import GitHubAPI
import GitHubClient
import HTTPServer
import JSON
import MongoDB
import SemanticVersions
import UnidocDB
import UnidocRecords
import UnixTime

extension GitHubPlugin
{
    struct Crawler
    {
        private
        let api:GitHubClient<GitHub.API>
        private
        let pat:String

        init(api:GitHubClient<GitHub.API>, pat:String)
        {
            self.api = api
            self.pat = pat
        }
    }
}
extension GitHubPlugin.Crawler
{
    func run(alongside server:Swiftinit.ServerLoop) async throws
    {
        while true
        {
            async
            let cooldown:Void = Task.sleep(for: .seconds(30))

            do
            {
                let session:Mongo.Session = try await .init(from: server.db.sessions)

                try await self.api.connect
                {
                    try await self.refresh(server.db,
                        counters: server.atomics,
                        count: 10,
                        from: $0,
                        with: session)
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

    private
    func refresh(_ db:Swiftinit.DB,
        counters:borrowing Swiftinit.Counters,
        count:Int,
        from github:GitHubClient<GitHub.API>.Connection,
        with session:Mongo.Session) async throws
    {
        let stale:[Unidoc.PackageMetadata] = try await db.packages.stalest(count,
            with: session)

        for package:Unidoc.PackageMetadata in stale
        {
            guard case .github(let old) = package.repo
            else
            {
                fatalError("unreachable: non-GitHub package was marked as stale!")
            }

            let response:GitHubPlugin.CrawlerResponse = try await github.crawl(
                owner: old.owner.login,
                repo: old.name,
                pat: self.pat)

            switch try await db.packages.update(record: .init(id: package.id,
                    symbol: package.symbol,
                    realm: package.realm,
                    repo: .github(response.repo),
                    crawled: .now()),
                with: session)
            {
            case nil:
                //  Might happen if package database is dropped while crawling.
                continue

            case _?:
                //  To MongoDB, all repo updates look like modifications, since the package
                //  record contains a timestamp.
                counters.reposCrawled.wrappingIncrement(ordering: .relaxed)
            }
            if  response.repo != old
            {
                counters.reposUpdated.wrappingIncrement(ordering: .relaxed)
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
                    counters.tagsUpdated.wrappingIncrement(ordering: .relaxed)

                    switch version
                    {
                    case .prerelease:   prerelease = edition.name
                    case .release:      release = edition.name
                    }

                    fallthrough

                case (_, new: false):
                    counters.tagsCrawled.wrappingIncrement(ordering: .relaxed)
                }
            }

            if  let interesting:String = release ?? prerelease,
                    response.repo.visibleInFeed
            {
                let activity:UnidocDatabase.RepoFeed.Activity = .init(discovered: .now(),
                    package: package.symbol,
                    refname: interesting,
                    origin: .github(response.repo.owner.login, response.repo.name))

                try await db.repoFeed.push(activity, with: session)
            }
        }
    }
}
