import URI

extension Site
{
    @frozen public
    enum Asset:String, Equatable, Hashable, Sendable
    {
        //  We let Google Fonts serve most of the fonts, but we host Literata ourselves because
        //  the front-end CSS uses opentype features such as old-style numerals, and Google
        //  Fonts strips those out.
        case literata45_woff2   = "text45.woff2"
        case literata47_woff2   = "text47.woff2"
        case literata75_woff2   = "text75.woff2"
        case literata77_woff2   = "text77.woff2"

        case main_css           = "main.css"
        case main_css_map       = "main.css.map"

        case main_js            = "main.js"
        case main_js_map        = "main.js.map"

        case robots_txt         = "robots.txt"
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
