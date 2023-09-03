extension ClientInterface
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
