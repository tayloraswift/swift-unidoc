import BSON
import GitHubAPI
import MongoQL
import UnidocRecords
import UnixCalendar
import UnixTime

extension Unidoc.PackageRepo:Mongo.MasterCodingModel
{
}
extension Unidoc.PackageRepo
{
    @inlinable public static
    func github(_ repo:GitHub.Repo, crawled:UnixMillisecond) throws -> Self
    {
        guard
        let created:Timestamp.Components = .init(iso8601: repo.created),
        let created:UnixAttosecond = .init(utc: created)
        else
        {
            throw Unidoc.GitHubRepoMetadataError.created(repo.created)
        }

        guard
        let updated:Timestamp.Components = .init(iso8601: repo.updated),
        let updated:UnixAttosecond = .init(utc: updated)
        else
        {
            throw Unidoc.GitHubRepoMetadataError.updated(repo.updated)
        }

        guard
        let pushed:Timestamp.Components = .init(iso8601: repo.pushed),
        let pushed:UnixAttosecond = .init(utc: pushed)
        else
        {
            throw Unidoc.GitHubRepoMetadataError.pushed(repo.pushed)
        }

        return .init(crawled: crawled,
            fetched: nil,
            expires: nil,
            account: .init(type: .github, user: repo.owner.id),
            created: .init(truncating: created),
            updated: .init(truncating: updated),
            license: repo.license.map { .init(spdx: $0.id, name: $0.name) },
            topics: repo.topics,
            master: repo.master,
            origin: .github(.init(
                id: repo.id,
                pushed: .init(truncating: pushed),
                owner: repo.owner.login,
                name: repo.name,
                homepage: repo.homepage,
                about: repo.about,
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
    func dormant(by now:UnixAttosecond) -> Duration?
    {
        let pushed:UnixMillisecond

        switch self.origin
        {
        case .github(let origin):   pushed = origin.pushed
        }

        let dormancy:Duration = now - .init(pushed)
        //  If the repo has been dormant for two years, we consider it abandoned.
        if  dormancy > .seconds(60 * 60 * 24 * 365 * 2)
        {
            return dormancy
        }
        else
        {
            return nil
        }
    }

    public
    func crawlingIntervalTarget(
        dormant:Duration?,
        hidden:Bool,
        realm:Unidoc.Realm?) -> Milliseconds?
    {
        guard self.origin.alive
        else
        {
            //  Repo has been deleted from, archived in, or disabled by the registrar.
            return nil
        }

        var interval:Milliseconds = .zero

        switch self.license?.free
        {
        //  The license is free.
        case true?:     interval += .minute * 10
        //  No license. The package is probably new and the author hasn’t gotten around to
        //  adding a license yet.
        case nil:       interval += .day * 3
        //  The license is intentionally unfree.
        case false?:    return nil
        }

        //  Deprioritize hidden packages.
        if  hidden
        {
            interval += .hour * 1
        }
        //  Prioritize packages with more stars. (We currently only index packages with at
        //  least two stars.)
        //
        //  If the package is part of the `public` realm (or whatever realm `0` has been named),
        //  we consider it to have infinite stars, and we do not care about dormancy.
        if  case 0? = realm
        {
            return interval
        }

        switch self.stars
        {
        case    0 ...    2: interval += .day * 4
        case    3 ...   10: interval += .day * 3
        case   11 ...   20: interval += .day * 2
        case   21 ...   50: interval += .day * 1
        case   51 ...   99: interval += .hour * 12
        case  100 ...  499: interval += .hour * 8
        case  500 ...  999: interval += .hour * 5
        case 1000 ... 1999: interval += .hour * 4
        case 2000 ... 2999: interval += .hour * 3
        case 3000 ... 3999: interval += .hour * 2
        case 4000 ... 4999: interval += .hour * 1
        default:        break
        }

        //  Deprioritize dormant packages.
        if  case _? = dormant
        {
            interval += .day * 7
        }

        return interval
    }
}
