extension Swiftinit.API
{
    @frozen public
    enum Post:String, Swiftinit.Method
    {
        case packageAlias = "package-alias"
        case packageAlign = "package-align"
        case packageConfig = "package-config"
        case packageIndex = "package-index"
        case packageIndexTag = "package-index-tag"

        case robots_txt = "robots.txt"

        case telescope = "telescope"

        case uplinkAll = "uplink-all"
        case uplink
        case unlink
        case delete

        case userConfig = "user-config"
    }
}
