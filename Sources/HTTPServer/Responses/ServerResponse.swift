import Media

@frozen public
enum ServerResponse:Equatable, Sendable
{
    case redirect(ServerRedirect)
    case resource(ServerResource)
}
