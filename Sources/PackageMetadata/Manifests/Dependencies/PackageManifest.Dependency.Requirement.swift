import ModuleGraphs
import SemanticVersions

extension PackageManifest.Dependency
{
    @frozen public
    enum Requirement:Hashable, Equatable, Sendable
    {
        case refname    (String)
        case revision   (Repository.Revision)
        case stable     (Repository.Requirement)
    }
}
