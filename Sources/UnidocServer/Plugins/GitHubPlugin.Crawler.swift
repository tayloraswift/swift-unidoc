import HTTPServer
import GitHubAPI
import GitHubClient
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
    func run(updating db:Server.DB, counters:borrowing Server.Counters) async throws
    {
        while true
        {
            async
            let cooldown:Void = Task.sleep(for: .seconds(30))

            let session:Mongo.Session = try await .init(from: db.sessions)
            do
            {
                try await self.api.connect
                {
                    try await self.refresh(db,
                        counters: counters,
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
                counters.errorsCrawling.wrappingIncrement(ordering: .relaxed)
            }

            try await cooldown
        }
    }

    private
    func refresh(_ db:Server.DB,
        counters:borrowing Server.Counters,
        count:Int,
        from github:GitHubClient<GitHub.API>.Connection,
        with session:Mongo.Session) async throws
    {
        let stale:[Realm.Package] = try await db.unidoc.packages.stalest(count,
            with: session)

        for package:Realm.Package in stale
        {
            guard case .github(let old) = package.repo
            else
            {
                fatalError("unreachable: non-GitHub package was marked as stale!")
            }

            let response:Response = try await github.crawl(owner: old.owner.login,
                repo: old.name,
                pat: self.pat)

            switch try await db.unidoc.packages.update(record: .init(id: package.id,
                    coordinate: package.coordinate,
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

                switch try await db.unidoc.editions.register(tag,
                    package: package.coordinate,
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
                let activity:UnidocDatabase.RepoFeed.Activity = .init(discovered: .now(),
                    package: package.id,
                    refname: interesting,
                    origin: .github(response.repo.owner.login, response.repo.name))

                try await db.unidoc.repoFeed.push(activity, with: session)
            }
        }
    }
}
