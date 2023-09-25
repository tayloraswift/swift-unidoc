import GitHubAPI
import UnixTime

extension GitHubClient
{
    @frozen public
    struct RateLimitError:GitHubRateLimitError, Equatable, Sendable
    {
        public
        let until:UnixInstant

        @inlinable internal
        init(until:UnixInstant)
        {
            self.until = until
        }
    }
}
