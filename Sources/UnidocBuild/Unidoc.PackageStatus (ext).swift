import SemanticVersions
import UnidocAPI

extension Unidoc.PackageStatus
{
    func choose(force:Main.Options.Force?) -> Edition?
    {
        switch force
        {
        case .prerelease?:  return self.prerelease
        case .release?:     return self.release
        case nil:           break
        }

        /// Only build prereleases if the latest release has already been built, and
        /// the prerelease has a higher patch version.
        if  self.release.graphs == 0
        {
            return self.release
        }
        else if
            let prerelease:Edition = self.prerelease,
                prerelease.graphs == 0,
            let version:SemanticVersion = .init(refname: prerelease.tag),
            let release:SemanticVersion = .init(refname: self.release.tag),
                release.patch < version.patch
        {
            return prerelease
        }
        else
        {
            return nil
        }
    }
}
