import UnidocAutomation

extension UnidocAPI
{
    @frozen public
    enum Post:String
    {
        case indexRepo = "index-repo"
        case indexRepoTag = "index-repo-tag"
        case uplink
        case unlink
    }
}
extension UnidocAPI.Post:StaticAPI
{
}
