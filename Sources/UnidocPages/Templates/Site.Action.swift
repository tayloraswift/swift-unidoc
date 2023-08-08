import URI

extension Site
{
    @frozen public
    enum Action:String, Equatable, Hashable, Sendable
    {
        case dropDatabase   = "drop-database"
        case rebuild        = "rebuild"
        case upload         = "upload"
    }
}
extension Site.Action:FixedRoot
{
    @inlinable public static
    var root:String { "action" }
}
extension Site.Action:CustomStringConvertible
{
}
