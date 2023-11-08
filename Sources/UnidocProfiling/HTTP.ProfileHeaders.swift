import HTTP

extension HTTP
{
    @frozen public
    struct ProfileHeaders:Equatable, Sendable
    {
        public
        var acceptLanguage:String?
        public
        var userAgent:String?
        public
        var referer:String?

        @inlinable public
        init(
            acceptLanguage:String? = nil,
            userAgent:String? = nil,
            referer:String? = nil)
        {
            self.acceptLanguage = acceptLanguage
            self.userAgent = userAgent
            self.referer = referer
        }
    }
}
