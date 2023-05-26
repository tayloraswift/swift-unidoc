import ModuleGraphs

extension PackageNode
{
    @frozen public
    enum Dependency:Equatable, Sendable
    {
        case filesystem(Filesystem)
        case resolvable(Resolvable)
        case transitive(PackageIdentifier)
    }
}
extension PackageNode.Dependency:Identifiable
{
    @inlinable public
    var id:PackageIdentifier
    {
        switch self
        {
        case .filesystem(let dependency): return dependency.id
        case .resolvable(let dependency): return dependency.id
        case .transitive(let dependency): return dependency
        }
    }
}
extension PackageNode.Dependency
{
    @inlinable public
    var requirement:Requirement?
    {
        if  case .resolvable(let dependency) = self
        {
            return dependency.requirement
        }
        else
        {
            return nil
        }
    }
}
