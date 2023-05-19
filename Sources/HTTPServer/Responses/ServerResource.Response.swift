import Media

extension ServerResource
{
    @frozen public
    enum Response:Equatable, Sendable
    {
        case content(Content)
        case redirect(Redirect)
    }
}
