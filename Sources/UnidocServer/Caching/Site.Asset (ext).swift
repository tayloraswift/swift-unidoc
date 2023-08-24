import Media
import System
import UnidocPages

extension Site.Asset:CacheKey
{
    /// Indicates if the asset should never be reloaded (``CacheReloading cold``),
    /// served only when hot-reloading is enabled (``CacheReloading hot``), or reloaded
    /// depending on whether hot-reloading is enabled (`nil`).
    var requirement:CacheReloading?
    {
        switch self
        {
        case    .literata45_woff2,
                .literata47_woff2,
                .literata75_woff2,
                .literata77_woff2:  return .cold
        case    .main_css,
                .main_js:           return nil
        case    .main_css_map,
                .main_js_map:       return .hot
        }
    }

    var source:[FilePath.Component]
    {
        switch self
        {
        case .literata45_woff2: return ["woff2", "Literata_24pt-Regular.woff2"]
        case .literata47_woff2: return ["woff2", "Literata_24pt-Italic.woff2"]
        case .literata75_woff2: return ["woff2", "Literata_24pt-Bold.woff2"]
        case .literata77_woff2: return ["woff2", "Literata_24pt-BoldItalic.woff2"]
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
        case    .literata45_woff2,
                .literata47_woff2,
                .literata75_woff2,
                .literata77_woff2:  return .font(.woff2)
        case    .main_css:          return .text(.css, charset: .utf8)
        case    .main_js:           return .text(.javascript, charset: .utf8)
        case    .main_css_map,
                .main_js_map:       return .application(.json, charset: .utf8)
        }
    }
}
