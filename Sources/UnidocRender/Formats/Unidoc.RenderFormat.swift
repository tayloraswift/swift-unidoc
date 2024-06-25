import HTTP
import Media
import UnixTime

extension Unidoc
{
    @frozen public
    struct RenderFormat
    {
        public
        var security:ServerSecurity
        public
        var username:String?
        public
        var locale:HTTP.Locale?
        public
        let assets:Assets
        public
        var server:ServerType

        public
        let time:UnixInstant

        @inlinable public
        init(
            security:ServerSecurity,
            username:String?,
            locale:HTTP.Locale?,
            assets:Assets,
            server:ServerType,
            time:UnixInstant = .now())
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
    var cornice:Unidoc.ApplicationCornice
    {
        if  case .swiftinit_org = self.server
        {
            .init(username: self.username, official: true)
        }
        else
        {
            .init(username: self.username, official: false)
        }
    }
}
