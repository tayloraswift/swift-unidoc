extension TargetNode
{
    /// A transparent wrapper around an array of `Dependency<String>` that yields
    /// the names of the target dependencies as a ``RandomAccessCollection``.
    @frozen public
    struct Predecessors
    {
        @usableFromInline internal
        let base:[Dependency<String>]

        @inlinable internal
        init(_ base:[Dependency<String>])
        {
            self.base = base
        }
    }
}
extension TargetNode.Predecessors:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { self.base.startIndex }

    @inlinable public
    var endIndex:Int { self.base.endIndex }

    @inlinable public
    subscript(position:Int) -> String
    {
        self.base[position].id
    }
}
