@frozen public
struct SymbolPath:Hashable, Sendable
{
    public 
    var prefix:[String]
    public 
    var last:String

    @inlinable public
    init(prefix:[String] = [], last:String)
    {
        self.last = last
        self.prefix = prefix 
    }
}
extension SymbolPath
{
    @inlinable public
    init?(_ components:some BidirectionalCollection<String>) 
    {
        guard let last:String = components.last 
        else 
        {
            return nil 
        }
        self.last = last 
        self.prefix = .init(components.dropLast())
    }

    @inlinable public mutating 
    func append(_ component:String)
    {
        self.prefix.append(self.last)
        self.last = component
    }
}
extension SymbolPath:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.lexicographicallyPrecedes(rhs)
    }
}
extension SymbolPath:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int 
    {
        self.prefix.startIndex
    }
    @inlinable public
    var endIndex:Int 
    {
        self.prefix.endIndex + 1
    }
    @inlinable public
    subscript(index:Int) -> String
    {
        _read 
        {
            if index == self.prefix.endIndex 
            {
                yield self.last 
            }
            else 
            {
                yield self.prefix[index]
            }
        }
        _modify 
        {
            if index == self.prefix.endIndex 
            {
                yield &self.last 
            }
            else 
            {
                yield &self.prefix[index]
            }
        }
    }
}
extension SymbolPath:CustomStringConvertible
{
    @inlinable public
    var description:String 
    {
        self.joined(separator: ".")
    }
}
