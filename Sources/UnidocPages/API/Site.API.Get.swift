extension Site.API
{
    @frozen public
    enum Get:String
    {
        case github
        case register
    }
}
extension Site.API.Get:StaticAPI
{
}
