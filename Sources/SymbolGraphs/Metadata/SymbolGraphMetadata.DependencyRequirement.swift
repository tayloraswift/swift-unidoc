import SemanticVersions

extension SymbolGraphMetadata
{
    @frozen public
    enum DependencyRequirement:Equatable, Hashable, Sendable
    {
        case exact(SemanticVersion)
        case range(SemanticVersion, to:SemanticVersion)
    }
}
extension SymbolGraphMetadata.DependencyRequirement
{
    @inlinable public
    init?(
        lowerNumber:PatchVersion?,
        lowerSuffix:SemanticVersion.Suffix?,
        upperNumber:PatchVersion?,
        upperSuffix:SemanticVersion.Suffix?)
    {
        guard
        let lowerNumber:PatchVersion
        else
        {
            return nil
        }

        let lower:SemanticVersion = .init(
            number: lowerNumber,
            suffix: lowerSuffix ?? .release())

        if  let upperNumber:PatchVersion,
                upperNumber >= lowerNumber
        {
            let upper:SemanticVersion = .init(number: upperNumber,
                suffix: upperSuffix ?? .release())

            self = .range(lower, to: upper)
        }
        else
        {
            self = .exact(lower)
        }
    }
}
