extension Swiftinit.API
{
    @frozen public
    enum Post:String, Swiftinit.Method
    {
        case alignPackage = "align-package"
        case indexRepo = "index-repo"
        case indexRepoTag = "index-repo-tag"
        case uplinkAll = "uplink-all"
        case uplink
        case unlink
    }
}
