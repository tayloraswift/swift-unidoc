import UnixTime

extension GitHub {
    public protocol RateLimitError: Error, Equatable, Sendable {
        /// The UTC epoch second when the rate limit will reset.
        var until: UnixAttosecond { get }
    }
}
