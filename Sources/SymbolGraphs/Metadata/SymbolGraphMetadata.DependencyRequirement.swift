import SemanticVersions

extension SymbolGraphMetadata
{
    @frozen public
    enum DependencyRequirement:Equatable, Hashable, Sendable
    {
        case exact        (PatchVersion)
        case range  (Range<PatchVersion>)
    }
}
