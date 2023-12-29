import UnixTime

extension GitHub
{
    public
    typealias RateLimitError = _GitHubRateLimitError
}

/// The name of this protocol is ``GitHub.RateLimitError``.
public
protocol _GitHubRateLimitError:Error, Equatable, Sendable
{
    /// The UTC epoch second when the rate limit will reset.
    var until:UnixInstant { get }
}
