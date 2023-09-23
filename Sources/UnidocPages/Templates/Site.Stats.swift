extension Site
{
    @frozen public
    enum Stats
    {
    }
}
extension Site.Stats:StaticRoot
{
    @inlinable public static
    var root:String { "stats" }
}
