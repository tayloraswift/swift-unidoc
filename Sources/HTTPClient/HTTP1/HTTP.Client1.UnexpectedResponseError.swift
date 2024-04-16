extension HTTP.Client1
{
    @frozen public
    struct UnexpectedResponseError:Error, Sendable
    {
        @inlinable public
        init()
        {
        }
    }
}
