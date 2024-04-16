extension HTTP.Client2
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
