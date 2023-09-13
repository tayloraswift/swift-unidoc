extension Site.API
{
    @frozen public
    enum Post:String
    {
        case index
    }
}
extension Site.API.Post:FixedAPI
{
}
