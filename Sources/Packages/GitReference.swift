import SemanticVersions

public 
enum GitReference:Hashable, Equatable, Sendable
{
    case version(SemanticVersion)
    case branch(String)
}
