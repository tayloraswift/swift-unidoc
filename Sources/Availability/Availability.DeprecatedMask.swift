import SemanticVersions

extension Availability
{
    @frozen public 
    enum DeprecatedMask:Hashable, Sendable
    {
        case unconditionally
        case since(SemanticVersionMask)
    }
}
