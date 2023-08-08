extension Site
{
    @frozen public
    enum Guides
    {
    }
}
extension Site.Guides:FixedRoot
{
    @inlinable public static
    var root:String { "guides" }
}
