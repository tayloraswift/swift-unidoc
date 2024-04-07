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
        var locale:HTTP.Locale?
        public
        var server:Server

        @inlinable public
        init(
            assets:Assets,
            locale:HTTP.Locale? = nil,
            server:Server = .swiftinit_org)
        {
            self.assets = assets
            self.locale = locale
            self.server = server
        }
    }
}
extension Unidoc.RenderFormat
{
    @inlinable public
    var secure:Bool
    {
        switch self.server
        {
        case .swiftinit_org:    true
        case .localhost:        false
        }
    }
}
