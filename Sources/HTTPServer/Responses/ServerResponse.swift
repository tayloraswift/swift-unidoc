import Media

@frozen public
enum ServerResponse:Equatable, Sendable
{
    case redirect(ServerRedirect, cookies:[Cookie] = [])
    case resource(ServerResource)
}
