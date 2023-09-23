extension Site
{
    @frozen public
    enum Docs
    {
    }
}
extension Site.Docs:StaticRoot
{
    @inlinable public static
    var root:String { "docs" }
}
