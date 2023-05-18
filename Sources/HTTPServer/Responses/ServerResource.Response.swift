import Media

extension ServerResource
{
    @frozen public
    enum Response:Equatable, Sendable
    {
        case media(MediaContent)
        case redirect(ServerRedirect)
    }
}
