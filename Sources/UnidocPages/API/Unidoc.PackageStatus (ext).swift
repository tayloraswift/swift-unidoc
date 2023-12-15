import UnidocAPI
import UnidocDB
import UnidocQueries

extension Unidoc.PackageStatus
{
    init?(from output:Unidoc.EditionsQuery.Output)
    {
        guard
        let repo:Unidoc.PackageMetadata.Repo = output.package.repo,
        let release:Unidoc.EditionOutput = output.releases.first,
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
