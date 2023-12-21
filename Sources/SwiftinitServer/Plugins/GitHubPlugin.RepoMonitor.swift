import GitHubAPI
import GitHubClient
import MongoDB
import SemanticVersions
import UnidocDB
import UnidocRecords

extension GitHubPlugin
{
    struct RepoMonitor
    {
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
extension GitHubPlugin.RepoMonitor:GitHubCrawler
{
    static
    var interval:Duration { .seconds(30) }

    func crawl(updating server:Swiftinit.ServerLoop,
        over connection:GitHubClient<GitHub.API>.Connection,
        with session:Mongo.Session) async throws
    {
        let stale:[Unidoc.PackageMetadata] = try await server.db.packages.stalest(10,
            with: session)

        for var package:Unidoc.PackageMetadata in stale
        {
            guard case .github(let old) = package.repo
            else
            {
                fatalError("unreachable: non-GitHub package was marked as stale!")
            }

            let response:GitHubPlugin.RepoMonitorResponse = try await connection.crawl(
                owner: old.owner.login,
                repo: old.name,
                pat: self.pat)

            package.repo = .github(response.repo)
            package.crawled = .now()

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
            if  response.repo != old
            {
                server.atomics.reposUpdated.wrappingIncrement(ordering: .relaxed)
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
                    refname: interesting,
                    origin: .github(response.repo.owner.login, response.repo.name))

                try await server.db.repoFeed.push(activity, with: session)
            }
        }
    }
}
