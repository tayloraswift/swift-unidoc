import SemanticVersions

extension Repository
{
    @frozen public
    enum Requirement:Equatable, Hashable, Sendable
    {
        case exact        (PatchVersion)
        case range  (Range<PatchVersion>)
    }
}
