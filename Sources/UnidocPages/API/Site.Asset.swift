import URI

extension Site
{
    public
    enum Asset
    {
    }
}
extension Site.Asset:StaticRoot
{
    @inlinable public static
    var root:String { "asset" }
}
