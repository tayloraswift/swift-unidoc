import BSON
import GitHubAPI
import MongoQL
import UnidocRecords
import UnixTime

extension Unidoc.PackageRepo:MongoMasterCodingModel
{
}
extension Unidoc.PackageRepo
{
    @inlinable public static
    func github(_ repo:GitHub.Repo, crawled:BSON.Millisecond) throws -> Self
    {
        guard
        let created:Timestamp.Components = .init(iso8601: repo.created),
        let created:UnixInstant = .init(utc: .date(created))
        else
        {
            throw Unidoc.GitHubTimestampError.created(repo.created)
        }

        guard
        let updated:Timestamp.Components = .init(iso8601: repo.updated),
        let updated:UnixInstant = .init(utc: updated)
        else
        {
            throw Unidoc.GitHubTimestampError.updated(repo.updated)
        }

        guard
        let pushed:Timestamp.Components = .init(iso8601: repo.pushed),
        let pushed:UnixInstant = .init(utc: pushed)
        else
        {
            throw Unidoc.GitHubTimestampError.pushed(repo.pushed)
        }

        return .init(crawled: crawled,
            created: .init(created),
            updated: .init(updated),
            license: repo.license.map { .init(spdx: $0.id, name: $0.name) },
            topics: repo.topics,
            master: repo.master,
            origin: .github(.init(
                id: repo.id,
                pushed: .init(pushed),
                owner: repo.owner.login,
                name: repo.name,
                homepage: repo.homepage,
                about: repo.about,
                watchers: repo.watchers,
                size: repo.size,
                archived: repo.archived,
                disabled: repo.disabled,
                fork: repo.fork)),
            forks: repo.forks,
            stars: repo.stars)
    }
}
