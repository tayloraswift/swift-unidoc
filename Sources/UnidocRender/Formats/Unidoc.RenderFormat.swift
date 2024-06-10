import HTTP
import Media
import UnixTime

extension Unidoc
{
    @frozen public
    struct RenderFormat
    {
        public
        let assets:Assets
        public
        var security:ServerSecurity
        public
        var locale:HTTP.Locale?
        public
        var server:ServerType

        public
        let time:UnixInstant

        @inlinable public
        init(
            assets:Assets,
            security:ServerSecurity,
            locale:HTTP.Locale? = nil,
            server:ServerType = .swiftinit_org,
            time:UnixInstant = .now())
        {
            self.assets = assets
            self.locale = locale
            self.security = security
            self.server = server
            self.time = time
        }
    }
}

