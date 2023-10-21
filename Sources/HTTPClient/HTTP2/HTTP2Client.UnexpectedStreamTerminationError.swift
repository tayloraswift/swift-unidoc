extension HTTP2Client
{
    @frozen public
    struct UnexpectedStreamTerminationError:Equatable, Error, Sendable
    {
        @inlinable public
        init()
        {
        }
    }
}
