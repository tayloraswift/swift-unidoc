extension HTTP.Resource {
    @frozen public struct Headers: Equatable, Hashable, Sendable {
        /// Contains a canonical URL for the resource, which is usually encoded within an HTTP
        /// `link` header.
        public var canonical: String?

        /// Contains any rate limit headers to send with the response.
        ///
        /// This name of this property parrots the word “``RateLimit/limit``” because the
        /// corresponding HTTP header is usually spelled as some variation of
        /// “`ratelimit-limit`”.
        public var rateLimit: RateLimit

        @inlinable public init(canonical: String? = nil, rateLimit: RateLimit = .init()) {
            self.canonical = canonical
            self.rateLimit = rateLimit
        }
    }
}
