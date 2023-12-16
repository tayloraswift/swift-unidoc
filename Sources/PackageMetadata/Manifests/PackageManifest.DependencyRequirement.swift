import SHA1
import SymbolGraphs

extension PackageManifest
{
    @frozen public
    enum DependencyRequirement:Hashable, Equatable, Sendable
    {
        case refname    (String)
        case revision   (SHA1)
        case stable     (SymbolGraphMetadata.DependencyRequirement)
    }
}
extension PackageManifest.DependencyRequirement
{
    @inlinable public
    var stable:SymbolGraphMetadata.DependencyRequirement?
    {
        if  case .stable(let requirement) = self
        {
            requirement
        }
        else
        {
            nil
        }
    }
}
