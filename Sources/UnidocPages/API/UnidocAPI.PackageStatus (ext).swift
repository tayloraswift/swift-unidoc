import UnidocAutomation
import UnidocDB
import UnidocQueries
import UnidocRecords

extension UnidocAPI.PackageStatus
{
    init?(from output:PackageEditionsQuery.Output)
    {
        guard
        let repo:Realm.Repo = output.package.repo,
        let release:PackageEditionsQuery.Facet = output.releases.first,
        let release:Edition = .init(from: release)
        else
        {
            return nil
        }

        self.init(
            coordinate: output.package.coordinate,
            repo: "https://\(repo.origin)",
            release: release,
            prerelease: output.prereleases.first.flatMap(Edition.init(from:)))
    }
}
