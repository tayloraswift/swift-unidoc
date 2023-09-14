extension Site
{
    public
    enum API
    {
    }
}
extension Site.API:FixedRoot
{
    @inlinable public static
    var root:String { "api" }
}
