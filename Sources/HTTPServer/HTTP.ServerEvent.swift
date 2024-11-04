import HTTP

extension HTTP
{
    @frozen public
    enum ServerEvent:Sendable
    {
        case application(any Error)
        case http1(any Error)
        case http2(any Error)
        case tcp(any Error)
    }
}
