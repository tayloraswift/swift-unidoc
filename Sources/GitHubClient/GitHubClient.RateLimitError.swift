import GitHubAPI
import UnixTime

extension GitHubClient
{
    @frozen public
    struct RateLimitError:GitHubRateLimitError, Equatable, Sendable
    {
        public
        let until:UnixTime

        @inlinable internal
        init(until:UnixTime)
        {
            self.until = until
        }
    }
}
