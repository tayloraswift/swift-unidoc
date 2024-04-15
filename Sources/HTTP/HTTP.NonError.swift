extension HTTP
{
    /// A `NonError` is useful when you need to skip decoding a response you expect to never
    /// contain a decodable value, for example, if a server responds with `204 No Content`.
    @frozen public
    struct NonError:Equatable, Error
    {
        @inlinable public
        init()
        {
        }
    }
}
