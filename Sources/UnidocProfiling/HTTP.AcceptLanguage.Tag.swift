import HTTP

extension HTTP.AcceptLanguage
{
    @frozen public
    struct Tag:Equatable, Hashable, Sendable
    {
        public
        let locale:HTTP.Locale
        public
        let q:Double

        @inlinable public
        init(locale:HTTP.Locale, q:Double = 1.0)
        {
            self.locale = locale
            self.q = q
        }
    }
}
