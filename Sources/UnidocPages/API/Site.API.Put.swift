extension Site.API
{
    @frozen public
    enum Put:String
    {
        case symbolgraph
    }
}
extension Site.API.Put:StaticAPI
{
}
