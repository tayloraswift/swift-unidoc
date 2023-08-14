import Media
import System
import UnidocPages

extension Site.Asset:CacheKey
{
    var requirement:CacheReloading?
    {
        switch self
        {
        case    .main_css:      return nil
        case    .main_css_map:  return .hot
        }
    }

    var source:[FilePath.Component]
    {
        switch self
        {
        case .main_css:         return ["css", "Main.css"]
        case .main_css_map:     return ["css", "Main.css.map"]
        }
    }

    var type:MediaType
    {
        switch self
        {
        case    .main_css:      return .text(.css, charset: .utf8)
        case    .main_css_map:  return .application(.json, charset: .utf8)
        }
    }
}
