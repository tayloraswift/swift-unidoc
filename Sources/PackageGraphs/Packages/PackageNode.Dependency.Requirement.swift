import ModuleGraphs
import SemanticVersions

extension PackageNode.Dependency
{
    @frozen public
    enum Requirement:Hashable, Equatable, Sendable
    {
        case refname    (String)
        case revision   (Repository.Revision)
        case stable     (Repository.Requirement)
    }
}
extension PackageNode.Dependency.Requirement
{
    @inlinable public
    var stable:Repository.Requirement?
    {
        if  case .stable(let requirement) = self
        {
            return requirement
        }
        else
        {
            return nil
        }
    }
}
