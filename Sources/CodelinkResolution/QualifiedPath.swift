import LexicalPaths

/// A path that is statically known to contain at least two components.
/// Create one from a ``String`` and an ``UnqualifiedPath`` using the `/` operator.
@frozen public
struct QualifiedPath:Hashable, Sendable
{
    public
    var namespace:String
    public
    var suffix:UnqualifiedPath

    @inlinable internal
    init(_ namespace:String, _ suffix:UnqualifiedPath)
    {
        self.namespace = namespace
        self.suffix = suffix
    }
}
extension QualifiedPath
{
    @inlinable public
    var last:String
    {
        _read
        {
            yield  self.suffix.last
        }
        _modify
        {
            yield &self.suffix.last
        }
    }
}
extension QualifiedPath
{
    @inlinable public
    init?(_ components:some BidirectionalCollection<String>)
    {
        if  let namespace:String = components.first,
            let suffix:UnqualifiedPath = .init(components.dropFirst())
        {
            self.init(namespace, suffix)
        }
        else
        {
            return nil
        }
    }
}
extension QualifiedPath:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.namespace, lhs.suffix) < (rhs.namespace, rhs.suffix)
    }
}
extension QualifiedPath:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.suffix.startIndex - 1
    }
    @inlinable public
    var endIndex:Int
    {
        self.suffix.endIndex
    }
    @inlinable public
    subscript(index:Int) -> String
    {
        _read
        {
            if  index < self.suffix.startIndex
            {
                yield self.namespace
            }
            else
            {
                yield self.suffix[index]
            }
        }
        _modify
        {
            if  index < self.suffix.startIndex
            {
                yield &self.namespace
            }
            else
            {
                yield &self.suffix[index]
            }
        }
    }
}
extension QualifiedPath:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.joined(separator: ".")
    }
}
