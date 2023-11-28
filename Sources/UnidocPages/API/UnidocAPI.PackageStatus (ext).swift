import UnidocAutomation
import UnidocDB
import UnidocQueries
import UnidocRecords

extension UnidocAPI.PackageStatus
{
    init?(from output:Realm.EditionsQuery.Output)
    {
        guard
        let repo:Realm.Package.Repo = output.package.repo,
        let release:Realm.EditionsQuery.Facet = output.releases.first,
        let release:Edition = .init(from: release)
        else
        {
            return nil
        }

        self.init(
            coordinate: output.package.id,
            repo: "https://\(repo.origin)",
            release: release,
            prerelease: output.prereleases.first.flatMap(Edition.init(from:)))
    }
}
