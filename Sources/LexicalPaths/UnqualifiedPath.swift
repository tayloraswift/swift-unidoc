@frozen public
struct UnqualifiedPath:Hashable, Sendable
{
    @usableFromInline internal
    var components:LexicalComponents<String>

    @inlinable public
    init(_ prefix:[String], _ last:String)
    {
        self.components = .init(prefix, last)
    }
}
extension UnqualifiedPath
{
    @inlinable public
    var prefix:[String]
    {
        _read
        {
            yield  self.components.prefix
        }
        _modify
        {
            yield &self.components.prefix
        }
    }
    @inlinable public
    var last:String
    {
        _read
        {
            yield  self.components.last
        }
        _modify
        {
            yield &self.components.last
        }
    }
}
extension UnqualifiedPath
{
    @inlinable public
    init?(_ components:some BidirectionalCollection<String>)
    {
        if  let last:String = components.last
        {
            self.init(.init(components.dropLast()), last)
        }
        else
        {
            return nil
        }
    }

    @inlinable public mutating
    func append(_ component:String)
    {
        self.components.append(component)
    }
}
extension UnqualifiedPath:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.lexicographicallyPrecedes(rhs)
    }
}
extension UnqualifiedPath:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.components.prefix.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.components.prefix.endIndex + 1
    }
    @inlinable public
    subscript(index:Int) -> String
    {
        _read
        {
            if index < self.components.prefix.endIndex
            {
                yield self.components.prefix[index]
            }
            else
            {
                yield self.components.last
            }
        }
        _modify
        {
            if index < self.components.prefix.endIndex
            {
                yield &self.components.prefix[index]
            }
            else
            {
                yield &self.components.last
            }
        }
    }
}
extension UnqualifiedPath:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.joined(separator: ".")
    }
}
extension UnqualifiedPath:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(splitting: description[...]) { $0 == "." }
    }
}
extension UnqualifiedPath
{
    @inlinable public
    init(splitting stem:Substring, where predicate:(Character) throws -> Bool) rethrows
    {
        var prefix:[String] = []
        var start:String.Index = stem.startIndex

        while let end:String.Index = try stem[start...].firstIndex(where: predicate)
        {
            prefix.append(String.init(stem[start ..< end]))
            start = stem.index(after: end)
        }

        self.init(prefix, String.init(stem[start...]))
    }
}
