extension Site.API
{
    @frozen public
    enum Get:String
    {
        case build
        case github
        case register
    }
}
extension Site.API.Get:StaticAPI
{
}
