@frozen public
struct GenericParameter:Hashable, Equatable, Sendable
{
    public
    let name:String
    public
    let depth:UInt

    @inlinable
    public init(name:String, depth:UInt)
    {
        self.name = name
        self.depth = depth
    }
}
