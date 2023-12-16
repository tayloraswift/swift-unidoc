extension Swiftinit
{
    public
    enum Asset:String, CaseIterable, Hashable, Sendable
    {
        case error404_jpg       = "error404.jpg"

        case favicon_ico        = "favicon.ico"
        case favicon_png        = "favicon.png"

        //  We let Google Fonts serve most of the fonts, but we host Literata ourselves
        //  because the front-end CSS uses opentype features such as old-style numerals,
        //  and Google Fonts strips those out.
        case literata45_woff2   = "text45.woff2"
        case literata47_woff2   = "text47.woff2"
        case literata75_woff2   = "text75.woff2"
        case literata77_woff2   = "text77.woff2"


        case main_css           = "main.css"
        case main_css_map       = "main.css.map"

        case main_js            = "main.js"
        case main_js_map        = "main.js.map"


        case admin_css          = "admin.css"
        case admin_css_map      = "admin.css.map"
    }
}
extension Swiftinit.Asset:Swiftinit.StaticRoot
{
    @inlinable public static
    var root:String { "asset" }
}
extension Swiftinit.Asset:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
extension Swiftinit.Asset
{
    @inlinable public
    init?(_ description:String)
    {
        guard
        let asset:Self = .init(rawValue: description)
        else
        {
            return nil
        }

        self = asset
    }
}
extension Swiftinit.Asset
{
    @inlinable public
    var versioning:Versioning
    {
        switch self
        {
        case    .error404_jpg,
                .favicon_ico,
                .favicon_png,
                .literata45_woff2,
                .literata47_woff2,
                .literata75_woff2,
                .literata77_woff2:
            .none

        case    .main_css,
                .main_css_map,
                .main_js,
                .main_js_map:
            .major

        case    .admin_css,
                .admin_css_map:
            .minor
        }
    }
}
