import UnidocAutomation

extension UnidocAPI
{
    @frozen public
    enum Get:String
    {
        case build
    }
}
extension UnidocAPI.Get:StaticAPI
{
}
