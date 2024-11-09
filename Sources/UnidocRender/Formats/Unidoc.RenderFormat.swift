import HTTP
import ISO
import Media
import UnidocRecords
import UnixCalendar
import UnixTime

extension Unidoc
{
    @frozen public
    struct RenderFormat
    {
        public
        var security:Security
        public
        var username:String?
        public
        var locale:ISO.Locale
        public
        let assets:Assets
        public
        var server:ServerType
        /// If set, a `data-theme` attribute will be added to the `<body>` element.
        public
        var theme:String?

        public
        let time:UnixAttosecond

        @inlinable public
        init(
            security:Security,
            username:String?,
            locale:ISO.Locale,
            assets:Assets,
            server:ServerType,
            theme:String?,
            time:UnixAttosecond)
        {
            self.security = security
            self.username = username
            self.locale = locale
            self.assets = assets
            self.server = server
            self.time = time
        }
    }
}
extension Unidoc.RenderFormat
{
    @inlinable public
    var sitename:String
    {
        switch self.server
        {
        case .swiftinit_org:    "swiftinit"
        case .localhost:        "preview"
        }
    }

    @inlinable public
    var cornice:Unidoc.ApplicationCornice
    {
        .init(sitename: self.sitename, username: self.username)
    }
}
