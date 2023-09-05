extension GitHubClient
{
    @frozen public
    enum AuthenticationError:Error, Sendable
    {
        case status(StatusError)
        case response(any Error)
    }
}
