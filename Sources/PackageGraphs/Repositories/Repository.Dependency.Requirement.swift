import SemanticVersions

extension Repository.Dependency
{
    @frozen public
    enum Requirement:Hashable, Equatable, Sendable
    {
        case range      (Range<SemanticVersion>)
        case ref        (Repository.Ref)
        case revision   (Repository.Revision)
    }
}
