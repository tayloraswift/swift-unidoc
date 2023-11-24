extension Symbol
{
    @frozen public
    struct File:Equatable, Hashable, Sendable
    {
        /// The path to the relevant file, relative to some ``FileRoot``.
        public
        let path:String

        /// Creates a file identifier from a relative path.
        @inlinable public
        init(_ path:String)
        {
            self.path = path
        }
    }
}
extension Symbol.File
{
    /// Returns the last path component of the file ``path``, not including
    /// the path separator (one of `/` or `\`) itself.
    @inlinable public
    var last:Substring
    {
        if  let i:String.Index = self.path.lastIndex(where: { $0 == "/" || $0 == "\\" })
        {
            return self.path[self.path.index(after: i)...]
        }
        else
        {
            return self.path[...]
        }
    }
}
extension Symbol.File:CustomStringConvertible
{
    @inlinable public
    var description:String { self.path }
}
extension Symbol.File:RawRepresentable
{
    @inlinable public
    var rawValue:String { self.path }

    @inlinable public
    init(rawValue:String)
    {
        self.init(rawValue)
    }
}
extension Symbol.File:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.path < rhs.path
    }
}
extension Symbol.File:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
