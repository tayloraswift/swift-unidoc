import JSON

extension Unidoc
{
    @frozen public
    enum VersionSeries:Equatable, Sendable
    {
        case prerelease
        case release
    }
}
extension Unidoc.VersionSeries:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .prerelease:   "prerelease"
        case .release:      "release"
        }
    }
}
extension Unidoc.VersionSeries:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        switch description
        {
        case "prerelease":  self = .prerelease
        case "release":     self = .release
        default:            return nil
        }
    }
}
extension Unidoc.VersionSeries:JSONStringDecodable, JSONStringEncodable
{
}
