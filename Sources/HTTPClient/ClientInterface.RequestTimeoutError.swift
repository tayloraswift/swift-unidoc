extension ClientInterface
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
