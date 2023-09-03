extension HTTP2Client
{
    @frozen public
    struct RequestTimeoutError:Equatable, Error, Sendable
    {
        @inlinable public
        init()
        {
        }
    }
}
