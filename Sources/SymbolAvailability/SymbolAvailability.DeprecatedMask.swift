import SemanticVersions

extension SymbolAvailability
{
    @frozen public 
    enum DeprecatedMask:Hashable, Sendable
    {
        case unconditionally
        case since(SemanticVersionMask)
    }
}
