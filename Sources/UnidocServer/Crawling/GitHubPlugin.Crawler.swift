import HTTPServer
import GitHubAPI
import GitHubClient
import JSON
import MongoDB
import SemanticVersions
import UnidocDB
import UnixTime

extension GitHubPlugin
{
    struct Crawler
    {
        private
        let api:GitHubClient<GitHub.API>
        private
        let pat:String
        private
        let db:Server.DB

        init(api:GitHubClient<GitHub.API>, pat:String, db:Server.DB)
        {
            self.api = api
            self.pat = pat
            self.db = db
        }
    }
}
extension GitHubPlugin.Crawler
{
    func run(counters:borrowing Server.Counters) async throws
    {
        while true
        {
            async
            let cooldown:Void = Task.sleep(for: .seconds(30))

            let session:Mongo.Session = try await .init(from: self.db.sessions)
            do
            {
                try await self.api.connect
                {
                    try await self.refresh(updating: counters,
                        stalest: 10,
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
                Log[.warning] = "Crawling error: \(error)"
                counters.errorsCrawling.wrappingIncrement(ordering: .relaxed)
            }

            try await cooldown
        }
    }

    private
    func refresh(updating counters:borrowing Server.Counters,
        stalest count:Int,
        from github:GitHubClient<GitHub.API>.Connection,
        with session:Mongo.Session) async throws
    {
        let stale:[PackageRecord] = try await self.db.unidoc.packages.stalest(count,
            with: session)

        for package:PackageRecord in stale
        {
            guard case .github(let old) = package.repo
            else
            {
                fatalError("unreachable: non-GitHub package was marked as stale!")
            }

            let response:Response = try await github.crawl(owner: old.owner.login,
                repo: old.name,
                pat: self.pat)

            switch try await self.db.unidoc.packages.update(record: .init(id: package.id,
                    cell: package.cell,
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

                switch try await self.db.unidoc.editions.register(tag,
                    package: package.cell,
                    version: version,
                    with: session)
                {
                case _?:
                    counters.tagsUpdated.wrappingIncrement(ordering: .relaxed)

                    switch version
                    {
                    case .prerelease:   prerelease = tag.name
                    case .release:      release = tag.name
                    }

                    fallthrough

                case nil:
                    counters.tagsCrawled.wrappingIncrement(ordering: .relaxed)
                }
            }

            if  let interesting:String = release ?? prerelease
            {
                let activity:UnidocDatabase.RepoActivity = .init(discovered: .now(),
                    package: package.id,
                    refname: interesting,
                    origin: .github(response.repo.owner.login, response.repo.name))

                try await self.db.unidoc.repoFeed.push(activity, with: session)
            }
        }
    }
}
