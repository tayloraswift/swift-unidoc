extension Site.API
{
    @frozen public
    enum Get:String
    {
        case build
    }
}
extension Site.API.Get:StaticAPI
{
}
