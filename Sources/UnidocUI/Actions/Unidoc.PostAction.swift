import URI

extension Unidoc
{
    @frozen public
    enum PostAction:String, URI.Path.ComponentConvertible
    {
        case package

        case packageAlias = "package-alias"
        case packageAlign = "package-align"
        case packageConfig = "package-config"
        case packageIndex = "package-index"
        case packageRules = "package-rules"

        case robots_txt = "robots.txt"

        case telescope = "telescope"

        case uplinkAll = "uplink-all"
        case build

        case userConfig = "user-config"
        case userSyncPermissions = "user-sync-permissions"
    }
}
