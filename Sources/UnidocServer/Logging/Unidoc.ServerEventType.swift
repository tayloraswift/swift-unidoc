import HTTP

extension Unidoc
{
    @frozen public
    enum ServerEventType:Sendable
    {
        case global(ServerLog.Level)
        case plugin(String)
    }
}
