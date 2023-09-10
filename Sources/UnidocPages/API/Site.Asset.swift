import URI

extension Site
{
    public
    enum Asset
    {
    }
}
extension Site.Asset:FixedRoot
{
    @inlinable public static
    var root:String { "asset" }
}
