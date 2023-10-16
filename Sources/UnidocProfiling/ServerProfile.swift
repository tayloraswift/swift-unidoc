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
        toSearch:ByStatus,
        toOther:ByStatus
    )
    public
    var requests:
    (
        pages:ByAgent,
        bytes:ByAgent
    )

    @inlinable public
    init(
        languages:ByLanguage = [:],
        responses:
        (
            toBarbie:ByStatus,
            toBratz:ByStatus,
            toSearch:ByStatus,
            toOther:ByStatus
        ) = ([:], [:], [:], [:]),
        requests:
        (
            pages:ByAgent,
            bytes:ByAgent
        ) = ([:], [:]))
    {
        self.languages = languages
        self.responses = responses
        self.requests = requests
    }
}
