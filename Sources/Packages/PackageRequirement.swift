import SemanticVersions

public 
enum PackageRequirement:Hashable, Equatable, Sendable
{
    case version(SemanticVersion)
    case branch(String)
}
