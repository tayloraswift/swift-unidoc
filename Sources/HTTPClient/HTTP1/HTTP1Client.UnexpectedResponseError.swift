extension HTTP1Client
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
