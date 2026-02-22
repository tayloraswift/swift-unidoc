import GitHubAPI
import UnixTime

extension GitHub.Client {
    @frozen public struct RateLimitError: GitHub.RateLimitError, Equatable, Sendable {
        public let until: UnixAttosecond

        @inlinable internal init(until: UnixAttosecond) {
            self.until = until
        }
    }
}
