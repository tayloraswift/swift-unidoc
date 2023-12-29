import GitHubAPI
import UnixTime

extension GitHub.Client
{
    @frozen public
    struct RateLimitError:GitHub.RateLimitError, Equatable, Sendable
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
