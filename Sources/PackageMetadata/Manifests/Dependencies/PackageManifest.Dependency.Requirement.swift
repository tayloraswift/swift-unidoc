import PackageGraphs
import SemanticVersions

extension PackageManifest.Dependency
{
    @frozen public
    enum Requirement:Hashable, Equatable, Sendable
    {
        case exact            (SemanticVersion)
        case range      (Range<SemanticVersion>)
        case refname    (String)
        case revision   (Repository.Revision)
    }
}
