import UnidocAutomation

extension UnidocAPI
{
    @frozen public
    enum Post:String
    {
        case index
        case uplink
        case unlink
    }
}
extension UnidocAPI.Post:StaticAPI
{
}
