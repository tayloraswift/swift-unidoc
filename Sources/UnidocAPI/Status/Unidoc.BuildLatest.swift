extension Unidoc
{
    @frozen public
    enum BuildLatest:String, Sendable
    {
        case prerelease
        case release
    }
}
extension Unidoc.BuildLatest:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
extension Unidoc.BuildLatest:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String) { self.init(rawValue: description) }
}
