import BSON
import Durations
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

extension Unidoc.PackageRepo
{
    public
    func crawlingIntervalTarget(realm:Unidoc.Realm?, hidden:Bool) -> Milliseconds
    {
        guard self.origin.alive
        else
        {
            //  Repo has been deleted from, archived in, or disabled by the registrar.
            return .day * 30
        }

        var days:Int = 0

        switch self.license?.free
        {
        //  The license is free.
        case true?:     break
        //  No license. The package is probably new and the author hasn’t gotten around to
        //  adding a license yet.
        case nil:       days += 3
        //  The license is intentionally unfree.
        case false?:    days += 14
        }

        //  Deprioritize hidden packages.
        if  hidden
        {
            days += 1
        }
        //  Prioritize packages with more stars. (We currently only index packages with at
        //  least two stars.)
        //
        //  If the package is part of the `public` realm (or whatever realm `0` has been named),
        //  we consider it to have infinite stars.
        if  case 0? = realm
        {
            return .day * days
        }

        switch self.stars
        {
        case  0 ...  2: days += 3
        case  3 ... 10: days += 2
        case 11 ... 20: days += 1
        default:        break
        }

        return .day * days
    }
}
