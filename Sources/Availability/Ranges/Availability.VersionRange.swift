import SemanticVersions

extension Availability
{
    @frozen public
    enum VersionRange:Equatable, Hashable, Sendable
    {
        case since(SemanticVersionMask?)
    }
}
