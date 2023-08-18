import ModuleGraphs

@available(*, deprecated, message: "Do we really need this?")
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
@available(*, deprecated)
extension QualifiedPath
{
    public
    init(splitting stem:Record.Stem)
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
            self.init(ModuleIdentifier.init(stem.rawValue))
        }
    }
}
@available(*, deprecated)
extension QualifiedPath:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.lexicographicallyPrecedes(rhs)
    }
}
@available(*, deprecated)
extension QualifiedPath
{
    @inlinable public
    var first:String
    {
        "\(self.namespace)"
    }
    @inlinable public
    var last:String
    {
        self.names.last ?? self.first
    }
}
@available(*, deprecated)
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
        index < self.names.startIndex ? self.first : self.names[index]
    }
}
@available(*, deprecated)
extension QualifiedPath:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.joined(separator: ".")
    }
}