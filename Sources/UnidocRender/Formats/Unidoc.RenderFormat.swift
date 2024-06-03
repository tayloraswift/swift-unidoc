import HTTP
import Media

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

        @inlinable public
        init(
            assets:Assets,
            security:ServerSecurity,
            locale:HTTP.Locale? = nil,
            server:ServerType = .swiftinit_org)
        {
            self.assets = assets
            self.locale = locale
            self.security = security
            self.server = server
        }
    }
}

