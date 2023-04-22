import StringIdentifiers

@frozen public
struct FileIdentifier:Equatable, Hashable, Sendable
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
extension FileIdentifier:StringIdentifier
{
    @inlinable public
    var description:String
    {
        self.path
    }
}
extension FileIdentifier:ExpressibleByStringLiteral
{
}
extension FileIdentifier:Comparable
{
}
