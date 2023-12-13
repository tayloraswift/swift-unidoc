import UnidocAutomation

extension UnidocAPI
{
    @frozen public
    enum Post:String
    {
        case alignPackage = "align-package"
        case indexRepo = "index-repo"
        case indexRepoTag = "index-repo-tag"
        case uplink
        case unlink
    }
}
extension UnidocAPI.Post:StaticAPI
{
}
