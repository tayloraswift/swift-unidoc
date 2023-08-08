import URI

extension Site
{
    @frozen public
    enum Asset:String, Equatable, Hashable, Sendable
    {
        case fonts_css      = "fonts.css"
        case fonts_css_map  = "fonts.css.map"

        case main_css       = "main.css"
        case main_css_map   = "main.css.map"
    }
}
extension Site.Asset:FixedRoot
{
    @inlinable public static
    var root:String { "asset" }
}
extension Site.Asset:CustomStringConvertible
{
}
