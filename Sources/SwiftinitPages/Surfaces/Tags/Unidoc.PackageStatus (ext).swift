import UnidocAPI
import UnidocDB
import UnidocQueries

extension Unidoc.PackageStatus
{
    init?(from output:borrowing Unidoc.PackageQuery.Output)
    {
        guard
        let repo:Unidoc.PackageRepo = output.package.repo,
        let release:Unidoc.PackageQuery.Tag = output.releases.first,
        let release:Edition = .init(from: release)
        else
        {
            return nil
        }

        self.init(
            coordinate: output.package.id,
            repo: repo.origin.https,
            release: release,
            prerelease: output.prereleases.first.flatMap(Edition.init(from:)))
    }
}
