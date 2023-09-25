extension Site.API
{
    @frozen public
    enum Post:String
    {
        case index
        case uplink
    }
}
extension Site.API.Post:StaticAPI
{
}
