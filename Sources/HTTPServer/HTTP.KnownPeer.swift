import HTTP

extension HTTP
{
    @frozen public
    enum KnownPeer:Equatable, Hashable, Sendable
    {
        case googlebot
        case bingbot
    }
}
