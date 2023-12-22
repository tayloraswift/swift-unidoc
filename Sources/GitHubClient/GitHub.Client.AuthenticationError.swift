import HTTP

extension GitHub.Client
{
    @frozen public
    enum AuthenticationError:Error, Sendable
    {
        case status(HTTP.StatusError)
        case response(any Error)
    }
}
