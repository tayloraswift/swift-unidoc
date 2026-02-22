import HTTP
import ISO
import Media
import UnidocRecords
import UnixCalendar
import UnixTime

extension Unidoc {
    @frozen public struct RenderFormat {
        public var access: AccessControl
        public var assets: Assets
        public var origin: HTTP.ServerOrigin
        public var preview: Bool

        public var username: String?
        public var locale: ISO.Locale
        /// If set, a `data-theme` attribute will be added to the `<body>` element.
        public var theme: String?
        public var time: UnixAttosecond

        @inlinable public init(
            access: AccessControl,
            assets: Assets,
            origin: HTTP.ServerOrigin,
            preview: Bool,
            username: String?,
            locale: ISO.Locale,
            theme: String?,
            time: UnixAttosecond
        ) {
            self.access = access
            self.assets = assets
            self.origin = origin
            self.preview = preview

            self.username = username
            self.locale = locale
            self.theme = theme
            self.time = time
        }
    }
}
extension Unidoc.RenderFormat {
    @inlinable public var sitename: String { self.preview ? "preview" : "swiftinit" }

    @inlinable public var cornice: Unidoc.ApplicationCornice {
        .init(sitename: self.sitename, username: self.username)
    }
}
