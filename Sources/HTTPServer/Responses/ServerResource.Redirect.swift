extension ServerResource
{
    @frozen public
    enum Redirect:Equatable, Sendable
    {
        case permanent
        case temporary
    }
}
