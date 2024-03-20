extension HTTP.Resource.Headers
{
    @frozen public
    struct RateLimit:Equatable, Hashable, Sendable
    {
        /// The number of allowed requests remaining in the current rate limit period.
        public
        var remaining:Int?
        /// The maximum number of requests that a client is allowed to make in a given period.
        public
        var limit:Int?
        /// How long until the rate limit resets, commonly understood to be in seconds.
        public
        var reset:Int?

        @inlinable public
        init(remaining:Int? = nil, limit:Int? = nil, reset:Int? = nil)
        {
            self.remaining = remaining
            self.limit = limit
            self.reset = reset
        }
    }
}
