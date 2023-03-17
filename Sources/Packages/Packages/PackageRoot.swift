@frozen public
struct PackageRoot:Hashable, Equatable, Sendable
{
    /// The absolute path to the package root, without the `file://` prefix.
    public
    let path:String

    @inlinable public
    init(_ path:String)
    {
        self.path = path
    }
}
extension PackageRoot:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
extension PackageRoot:LosslessStringConvertible, CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.path
    }
}
