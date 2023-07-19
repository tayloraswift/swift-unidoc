import ModuleGraphs

@frozen public
struct QualifiedPath:Equatable, Hashable, Sendable
{
    public
    let namespace:ModuleIdentifier
    public
    var names:[String]

    @inlinable public
    init(_ namespace:ModuleIdentifier, _ names:[String] = [])
    {
        self.namespace = namespace
        self.names = names
    }
}
extension QualifiedPath
{
    public
    init?(splitting stem:Record.Stem)
    {
        if  let separator:String.Index = stem.rawValue.firstIndex(where: \.isWhitespace)
        {
            let namespace:ModuleIdentifier = .init(String.init(stem.rawValue[..<separator]))
            let names:Substring = stem.rawValue[stem.rawValue.index(after: separator)...]
            self.init(namespace, names.split(
                whereSeparator: \.isWhitespace).map(String.init(_:)))
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
        lhs.lexicographicallyPrecedes(rhs)
    }
}
extension QualifiedPath:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.names.startIndex - 1
    }
    @inlinable public
    var endIndex:Int
    {
        self.names.endIndex
    }
    @inlinable public
    subscript(index:Int) -> String
    {
        index < self.names.startIndex ? "\(self.namespace)" : self.names[index]
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
