import GitHubAPI
import GitHubClient
import MongoDB
import SemanticVersions
import UnidocDB
import UnixTime

extension GitHubPlugin
{
    struct Crawler
    {
        private
        let count:Counters
        private
        let api:GitHubClient<GitHubOAuth.API>
        private
        let db:Server.DB

        init(count:Counters, api:GitHubClient<GitHubOAuth.API>, db:Server.DB)
        {
            self.count = count
            self.api = api
            self.db = db
        }
    }
}
extension GitHubPlugin.Crawler
{
    func run() async throws
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
                    try await self.refresh(stalest: 10, from: $0, with: session)
                }
            }
            catch let error as any GitHubRateLimitError
            {
                try await Task.sleep(for: error.until - .now())
            }
            catch let error
            {
                print("Crawling error: \(error)")
                self.count.errors.wrappingIncrement(ordering: .relaxed)
            }

            try await cooldown
        }
    }

    private
    func refresh(stalest count:Int,
        from github:GitHubClient<GitHubOAuth.API>.Connection,
        with session:Mongo.Session) async throws
    {
        let stale:[PackageRecord] = try await self.db.package.packages.stalest(count,
            with: session)

        for package:PackageRecord in stale
        {
            guard case .github(let old) = package.repo
            else
            {
                fatalError("unreachable: non-GitHub package was marked as stale!")
            }

            let repo:GitHub.Repo = try await github.get(
                from: "/repos/\(old.owner.login)/\(old.name)")

            switch try await self.db.package.packages.update(record: .init(id: package.id,
                    cell: package.cell,
                    repo: .github(repo)),
                with: session)
            {
            case nil:
                //  Might happen if package database is dropped while crawling.
                continue

            case _?:
                //  To MongoDB, all repo updates look like modifications, since the package
                //  record contains a timestamp.
                self.count.reposCrawled.wrappingIncrement(ordering: .relaxed)
            }
            if  repo != old
            {
                self.count.reposUpdated.wrappingIncrement(ordering: .relaxed)
            }

            let tags:[GitHub.Tag] = try await github.get(
                from: "/repos/\(repo.owner.login)/\(repo.name)/tags")

            //  Import tags in chronological order.
            for tag:GitHub.Tag in tags.reversed()
            {
                guard
                let _:SemanticVersion = .init(refname: tag.name)
                else
                {
                    //  We don’t care about non-semver tags.
                    continue
                }

                switch try await self.db.package.editions.register(tag,
                    package: package.cell,
                    with: session)
                {
                case _?:
                    self.count.tagsUpdated.wrappingIncrement(ordering: .relaxed)
                    fallthrough

                case nil:
                    self.count.tagsCrawled.wrappingIncrement(ordering: .relaxed)
                }
            }
        }
    }
}
