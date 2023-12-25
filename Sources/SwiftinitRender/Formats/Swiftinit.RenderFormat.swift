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
        var accept:HTTP.AcceptType
        public
        var locale:HTTP.Locale?
        public
        var secure:Bool

        @inlinable public
        init(
            assets:Assets,
            accept:HTTP.AcceptType = .text(.html),
            locale:HTTP.Locale? = nil,
            secure:Bool = true)
        {
            self.assets = assets
            self.accept = accept
            self.locale = locale
            self.secure = secure
        }
    }
}
