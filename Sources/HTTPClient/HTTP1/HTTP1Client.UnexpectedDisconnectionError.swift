extension HTTP1Client
{
    @frozen public
    struct UnexpectedDisconnectionError:Equatable, Error, Sendable
    {
        @inlinable public
        init()
        {
        }
    }
}
