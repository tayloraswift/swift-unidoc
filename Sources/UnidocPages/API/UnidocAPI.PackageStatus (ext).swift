import UnidocAutomation
import UnidocDB
import UnidocQueries

extension UnidocAPI.PackageStatus
{
    init?(from output:PackageEditionsQuery.Output)
    {
        guard
        let repo:PackageRepo = output.record.repo,
        let release:PackageEditionsQuery.Facet = output.releases.first,
        let release:Edition = .init(from: release)
        else
        {
            return nil
        }

        self.init(
            coordinate: output.record.cell,
            repo: "https://\(repo.origin)",
            release: release,
            prerelease: output.prereleases.first.flatMap(Edition.init(from:)))
    }
}
