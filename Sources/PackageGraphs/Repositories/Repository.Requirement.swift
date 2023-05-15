import SemanticVersions

extension Repository
{
    @frozen public
    enum Requirement:Equatable, Hashable, Sendable
    {
        case exact        (SemanticVersion)
        case range  (Range<SemanticVersion>)
    }
}
