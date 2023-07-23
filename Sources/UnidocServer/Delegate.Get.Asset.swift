import Media
import System

extension Delegate.Get
{
    enum Asset:String, Equatable, Hashable, Sendable
    {
        case fonts_css      = "fonts.css"
        case fonts_css_map  = "fonts.css.map"

        case main_css       = "main.css"
        case main_css_map   = "main.css.map"
    }
}
extension Delegate.Get.Asset:CacheKey
{
    var requirement:CacheReloading?
    {
        switch self
        {
        case    .fonts_css,
                .main_css:      return nil
        case    .fonts_css_map,
                .main_css_map:  return .hot
        }
    }

    var source:[FilePath.Component]
    {
        switch self
        {
        case .fonts_css:        return ["css", "Fonts.css"]
        case .fonts_css_map:    return ["css", "Fonts.css.map"]
        case .main_css:         return ["css", "Main.css"]
        case .main_css_map:     return ["css", "Main.css.map"]
        }
    }

    var type:MediaType
    {
        switch self
        {
        case    .fonts_css,
                .main_css:      return .text(.css, charset: .utf8)

        case    .fonts_css_map,
                .main_css_map:  return .application(.json, charset: .utf8)
        }
    }
}
