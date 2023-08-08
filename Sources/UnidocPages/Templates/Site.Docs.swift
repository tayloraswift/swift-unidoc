extension Site
{
    @frozen public
    enum Docs
    {
    }
}
extension Site.Docs:FixedRoot
{
    @inlinable public static
    var root:String { "docs" }
}
