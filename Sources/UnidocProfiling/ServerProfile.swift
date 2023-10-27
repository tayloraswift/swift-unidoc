@frozen public
struct ServerProfile
{
    public
    var languages:ByLanguage
    public
    var protocols:
    (
        toBarbie:ByProtocol,
        toBratz:ByProtocol,
        toSearch:ByProtocol,
        toOther:ByProtocol
    )
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
        protocols:
        (
            toBarbie:ByProtocol,
            toBratz:ByProtocol,
            toSearch:ByProtocol,
            toOther:ByProtocol
        ) = ([:], [:], [:], [:]),
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
        self.protocols = protocols
        self.responses = responses
        self.requests = requests
    }
}
