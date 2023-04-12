@frozen public
struct LexicalPath:Hashable, Sendable
{
    @usableFromInline internal 
    var components:LexicalComponents<String>

    @inlinable public
    init(_ prefix:[String], _ last:String)
    {
        self.components = .init(prefix, last)
    }
}
extension LexicalPath
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
extension LexicalPath
{
    @inlinable public
    init?(_ components:some BidirectionalCollection<String>) 
    {
        if let last:String = components.last
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
extension LexicalPath:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.lexicographicallyPrecedes(rhs)
    }
}
extension LexicalPath:RandomAccessCollection
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
extension LexicalPath:CustomStringConvertible
{
    @inlinable public
    var description:String 
    {
        self.joined(separator: ".")
    }
}
