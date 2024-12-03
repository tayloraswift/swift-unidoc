import HTTP

extension Unidoc
{
    @frozen public
    enum ServerEventType:Sendable
    {
        case global(HTTP.LogLevel)
        case plugin(String)
    }
}
