@frozen public
struct Localhost:ServerAuthority
{
    @inlinable internal
    init()
    {
    }

    @inlinable public static
    var scheme:ServerScheme { .http }
    @inlinable public static
    var domain:String { "127.0.0.1" }
}
