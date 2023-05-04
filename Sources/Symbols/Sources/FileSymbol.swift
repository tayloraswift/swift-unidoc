@frozen public
struct FileSymbol:Equatable, Hashable, Sendable
{
    /// The path to the relevant file, relative to the package root.
    public
    let path:String

    /// Creates a file identifier from a relative path.
    @inlinable public
    init(_ path:String)
    {
        self.path = path
    }
}
extension FileSymbol:CustomStringConvertible
{
    @inlinable public
    var description:String { self.path }
}
extension FileSymbol:RawRepresentable
{
    @inlinable public
    var rawValue:String { self.path }

    @inlinable public
    init(rawValue:String)
    {
        self.init(rawValue)
    }
}
extension FileSymbol:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool 
    {
        lhs.path < rhs.path
    }
}
extension FileSymbol:ExpressibleByStringLiteral 
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
