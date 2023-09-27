extension Site.API
{
    @frozen public
    enum Post:String
    {
        case index
        case uplink
        case unlink
    }
}
extension Site.API.Post:StaticAPI
{
}
