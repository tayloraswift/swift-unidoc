@frozen public
struct ServerProfile
{
    public
    var languages:ByLanguage

    public
    var responses:
    (
        toBarbie:ByStatus,
        toBratz:ByStatus,
        toGooglebot:ByStatus,
        toBingbot:ByStatus,
        toOtherSearch:ByStatus,
        toOtherRobots:ByStatus
    )
    public
    var requests:
    (
        http2:ByClient,
        http1:ByClient,
        bytes:ByClient
    )

    @inlinable public
    init(
        languages:ByLanguage = [:],
        responses:
        (
            toBarbie:ByStatus,
            toBratz:ByStatus,
            toGooglebot:ByStatus,
            toBingbot:ByStatus,
            toOtherSearch:ByStatus,
            toOtherRobots:ByStatus
        ) = ([:], [:], [:], [:], [:], [:]),
        requests:
        (
            http2:ByClient,
            http1:ByClient,
            bytes:ByClient
        ) = ([:], [:], [:]))
    {
        self.languages = languages
        self.responses = responses
        self.requests = requests
    }
}
