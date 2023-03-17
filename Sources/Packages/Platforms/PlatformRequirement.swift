@frozen public
struct PlatformRequirement:Identifiable, Equatable, Hashable, Sendable
{
    public
    let id:PlatformIdentifier
    public
    let min:SemanticVersionMask

    @inlinable public
    init(id:PlatformIdentifier, min:SemanticVersionMask)
    {
        self.id = id
        self.min = min
    }
}
