extension Unidoc
{
    @frozen public
    enum LoggableEvent:Sendable
    {
        case client(ClientTriggeredEvent)
        case server(ServerTriggeredEvent)
    }
}
