@frozen public
enum GitHubAuthenticationError:Error, Sendable
{
    case fetch(any Error)
    case status
    case response(any Error)
}
