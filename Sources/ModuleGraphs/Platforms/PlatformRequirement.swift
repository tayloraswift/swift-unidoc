import SemanticVersions

@frozen public
struct PlatformRequirement:Identifiable, Equatable, Hashable, Sendable
{
    public
    let id:PlatformIdentifier
    public
    let min:NumericVersion

    @inlinable public
    init(id:PlatformIdentifier, min:NumericVersion)
    {
        self.id = id
        self.min = min
    }
}
