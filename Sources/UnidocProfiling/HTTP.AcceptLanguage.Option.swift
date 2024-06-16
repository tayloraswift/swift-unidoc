import HTTP

extension HTTP.AcceptLanguage
{
    @frozen public
    struct Option:Equatable, Hashable, Sendable
    {
        /// The `accept-language` locale, or `nil` for the wildcard (`*`).
        public
        let locale:HTTP.Locale?
        public
        let q:Double

        @inlinable public
        init(locale:HTTP.Locale?, q:Double)
        {
            self.locale = locale
            self.q = q
        }
    }
}
