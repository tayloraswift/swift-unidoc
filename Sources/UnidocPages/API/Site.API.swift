extension Site
{
    public
    enum API
    {
    }
}
extension Site.API:StaticRoot
{
    @inlinable public static
    var root:String { "api" }
}
