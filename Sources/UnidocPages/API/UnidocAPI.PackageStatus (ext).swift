import UnidocAutomation
import UnidocDB
import UnidocQueries
import UnidocRecords

extension UnidocAPI.PackageStatus
{
    init?(from output:Unidex.EditionsQuery.Output)
    {
        guard
        let repo:Unidoc.PackageMetadata.Repo = output.package.repo,
        let release:Unidex.EditionOutput = output.releases.first,
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
