extension Site
{
    @frozen public
    enum Stats
    {
    }
}
extension Site.Stats:FixedRoot
{
    @inlinable public static
    var root:String { "stats" }
}
