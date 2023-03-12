@frozen public
struct GenericParameter:Hashable, Equatable, Sendable
{
    public
    let name:String
    public
    let depth:Int

    @inlinable
    public init(name:String, depth:Int)
    {
        self.name = name
        self.depth = depth
    }
}
