import SemanticVersions

extension SymbolGraphMetadata
{
    @frozen public
    enum DependencyRequirement:Equatable, Hashable, Sendable
    {
        case exact(SemanticVersion)
        case range(SemanticVersion, to:PatchVersion)
    }
}
extension SymbolGraphMetadata.DependencyRequirement
{
    @inlinable public
    init?(suffix:SemanticVersion.Suffix?, lower:PatchVersion?, upper:PatchVersion?)
    {
        guard
        let version:PatchVersion = lower
        else
        {
            return nil
        }

        let suffix:SemanticVersion.Suffix =  suffix ?? .release()

        if  let upper:PatchVersion,
                upper >= version
        {
            self = .range(.init(number: version, suffix: suffix), to: upper)
        }
        else
        {
            self = .exact(.init(number: version, suffix: suffix))
        }
    }
}
