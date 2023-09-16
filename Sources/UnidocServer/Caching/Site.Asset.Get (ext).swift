import Media
import System
import UnidocPages

extension Site.Asset.Get:CacheKey
{
    /// Indicates if the asset will be reloaded from disk when hot-reloading is enabled.
    /// (Some assets will never be reloaded, such as the favicon.)
    var reloadable:Bool
    {
        switch self
        {
        case    .main_css,
                .main_css_map,
                .main_js,
                .main_js_map:
            return true

        case    _:
            return false
        }
    }

    var source:[FilePath.Component]
    {
        switch self
        {
        case .favicon_ico:      return ["icons", "favicon.ico"]
        case .favicon_png:      return ["icons", "favicon.png"]
        case .literata45_woff2: return ["woff2", "Literata_24pt-Regular.woff2"]
        case .literata47_woff2: return ["woff2", "Literata_24pt-Italic.woff2"]
        case .literata75_woff2: return ["woff2", "Literata_24pt-Bold.woff2"]
        case .literata77_woff2: return ["woff2", "Literata_24pt-BoldItalic.woff2"]
        case .robots_txt:       return ["robots.txt"]
        case .admin_css:        return ["css", "Admin.css"]
        case .admin_css_map:    return ["css", "Admin.css.map"]
        case .main_css:         return ["css", "Main.css"]
        case .main_css_map:     return ["css", "Main.css.map"]
        case .main_js:          return ["js", "Main.js"]
        case .main_js_map:      return ["js", "Main.js.map"]
        }
    }

    var type:MediaType
    {
        switch self
        {
        case    .favicon_ico:       return .image(.x_icon)
        case    .favicon_png:       return .image(.png)
        case    .robots_txt:        return .text(.plain, charset: .utf8)
        case    .literata45_woff2,
                .literata47_woff2,
                .literata75_woff2,
                .literata77_woff2:  return .font(.woff2)
        case    .admin_css,
                .main_css:          return .text(.css, charset: .utf8)
        case    .main_js:           return .text(.javascript, charset: .utf8)
        case    .admin_css_map,
                .main_css_map,
                .main_js_map:       return .application(.json, charset: .utf8)
        }
    }
}
