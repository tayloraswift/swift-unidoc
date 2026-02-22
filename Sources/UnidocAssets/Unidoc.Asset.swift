import SemanticVersions

extension Unidoc {
    @frozen public enum Asset: String, CaseIterable, Hashable, Sendable {
        case error404_jpg       = "error404.jpg"
        case error4xx_jpg       = "error4xx.jpg"
        case error500_jpg       = "error500.jpg"

        case favicon_ico        = "favicon.ico"
        case favicon_png        = "favicon.png"

        case github_jpg         = "github.jpg"

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
extension Unidoc.Asset: CustomStringConvertible {
    @inlinable public var description: String { self.rawValue }
}
extension Unidoc.Asset {
    @inlinable public init?(_ description: String) {
        guard
        let asset: Self = .init(rawValue: description) else {
            return nil
        }

        self = asset
    }
}
extension Unidoc.Asset {
    @inlinable public func path(prepending version: MajorVersion) -> String {
        self.versioned ? "/asset/\(version)/\(self)" : "/asset/\(self)"
    }

    @inlinable public var libre: Bool {
        switch self {
        case .error404_jpg:     false
        case .error4xx_jpg:     false
        case .error500_jpg:     false
        case .favicon_ico:      true
        case .favicon_png:      true
        case .github_jpg:       false
        case .literata45_woff2: true
        case .literata47_woff2: true
        case .literata75_woff2: true
        case .literata77_woff2: true
        case .main_css:         true
        case .main_css_map:     true
        case .main_js:          true
        case .main_js_map:      true
        case .admin_css:        false
        case .admin_css_map:    false
        }
    }

    @inlinable var versioned: Bool {
        switch self {
        case .error404_jpg:     false
        case .error4xx_jpg:     false
        case .error500_jpg:     false
        case .favicon_ico:      false
        case .favicon_png:      false
        case .github_jpg:       false
        case .literata45_woff2: false
        case .literata47_woff2: false
        case .literata75_woff2: false
        case .literata77_woff2: false
        case .main_css:         true
        case .main_css_map:     true
        case .main_js:          true
        case .main_js_map:      true
        case .admin_css:        true
        case .admin_css_map:    true
        }
    }
}
