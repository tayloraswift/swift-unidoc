import UnixTime

public
protocol GitHubRateLimitError:Error, Equatable, Sendable
{
    /// The UTC epoch second when the rate limit will reset.
    var until:UnixTime { get }
}
