extension Site
{
    public
    enum API
    {
    }
}
extension Site.API
{
    @frozen public
    enum Get:String
    {
        case github
        case register
    }
}
extension Site.API.Get:FixedAPI
{
}
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

extension Site.API:FixedRoot
{
    @inlinable public static
    var root:String { "api" }
}
