extension Site
{
    @frozen public
    enum Guides
    {
    }
}
extension Site.Guides:StaticRoot
{
    @inlinable public static
    var root:String { "guides" }
}
