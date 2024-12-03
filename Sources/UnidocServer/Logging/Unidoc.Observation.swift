extension Unidoc
{
    @frozen public
    enum Observation:Sendable
    {
        case client(ClientTriggered)
        case server(ServerTriggered)
    }
}
