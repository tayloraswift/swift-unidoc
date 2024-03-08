import HTTP
import Media

extension Swiftinit
{
    @frozen public
    struct RenderFormat
    {
        public
        let assets:Assets
        public
        var locale:HTTP.Locale?
        public
        var secure:Bool

        @inlinable public
        init(
            assets:Assets,
            locale:HTTP.Locale? = nil,
            secure:Bool = true)
        {
            self.assets = assets
            self.locale = locale
            self.secure = secure
        }
    }
}
