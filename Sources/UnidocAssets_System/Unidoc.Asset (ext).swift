import Media
import System
import UnidocAssets

extension Unidoc.Asset
{
    public
    var source:[FilePath.Component]
    {
        switch self
        {
        case .error404_jpg:     ["icons", "error404.jpg"]
        case .error4xx_jpg:     ["icons", "error4xx.jpg"]
        case .error500_jpg:     ["icons", "error500.jpg"]
        case .favicon_ico:      ["icons", "favicon.ico"]
        case .favicon_png:      ["icons", "favicon.png"]
        case .literata45_woff2: ["woff2", "Literata_24pt-Regular.woff2"]
        case .literata47_woff2: ["woff2", "Literata_24pt-Italic.woff2"]
        case .literata75_woff2: ["woff2", "Literata_24pt-Bold.woff2"]
        case .literata77_woff2: ["woff2", "Literata_24pt-BoldItalic.woff2"]
        case .admin_css:        ["css", "Admin.css"]
        case .admin_css_map:    ["css", "Admin.css.map"]
        case .main_css:         ["css", "Main.css"]
        case .main_css_map:     ["css", "Main.css.map"]
        case .main_js:          ["js", "Main.js"]
        case .main_js_map:      ["js", "Main.js.map"]
        }
    }

    public
    var type:MediaType
    {
        switch self
        {
        case .error404_jpg:     .image(.jpeg)
        case .error4xx_jpg:     .image(.jpeg)
        case .error500_jpg:     .image(.jpeg)
        case .favicon_ico:      .image(.x_icon)
        case .favicon_png:      .image(.png)
        case .literata45_woff2: .font(.woff2)
        case .literata47_woff2: .font(.woff2)
        case .literata75_woff2: .font(.woff2)
        case .literata77_woff2: .font(.woff2)
        case .admin_css:        .text(.css, charset: .utf8)
        case .main_css:         .text(.css, charset: .utf8)
        case .main_js:          .text(.javascript, charset: .utf8)
        case .admin_css_map:    .application(.json, charset: .utf8)
        case .main_css_map:     .application(.json, charset: .utf8)
        case .main_js_map:      .application(.json, charset: .utf8)
        }
    }
}
