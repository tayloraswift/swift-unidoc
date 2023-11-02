import UnidocAutomation

extension UnidocAPI
{
    @frozen public
    enum Put:String
    {
        case snapshot = "snapshot"
        case graph = "symbolgraph"
    }
}
extension UnidocAPI.Put:StaticAPI
{
}
