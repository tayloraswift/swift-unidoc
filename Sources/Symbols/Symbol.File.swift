extension Symbol
{
    @frozen public
    struct File:Equatable, Hashable, Sendable
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
