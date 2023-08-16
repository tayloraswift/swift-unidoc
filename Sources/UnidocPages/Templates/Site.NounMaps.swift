extension Site
{
    @frozen public
    enum NounMaps
    {
    }
}
extension Site.NounMaps:FixedRoot
{
    @inlinable public static
    var root:String { "nouns" }
}
