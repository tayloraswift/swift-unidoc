extension Unidoc
{
    @frozen public
    enum PostAction:String, Sendable
    {
        case packageAlias = "package-alias"
        case packageAlign = "package-align"
        case packageConfig = "package-config"
        case packageIndex = "package-index"

        case robots_txt = "robots.txt"

        case telescope = "telescope"

        case uplinkAll = "uplink-all"
        case uplink
        case unlink
        case delete
        case build

        case userConfig = "user-config"
    }
}
extension Unidoc.PostAction:LosslessStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }

    @inlinable public
    init?(_ description:String) { self.init(rawValue: description) }
}
