import ISO

extension HTTP
{
    @frozen public
    struct Locale:Equatable, Hashable, Sendable
    {
        public
        let language:ISO.Macrolanguage
        public
        let country:ISO.Country?

        @inlinable public
        init(language:ISO.Macrolanguage, country:ISO.Country? = nil)
        {
            self.language = language
            self.country = country
        }
    }
}
