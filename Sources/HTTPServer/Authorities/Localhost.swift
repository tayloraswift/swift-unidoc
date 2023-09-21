import NIOSSL

@frozen public
struct Localhost:ServerAuthority
{
    public
    let tls:NIOSSLContext

    @inlinable public
    init(tls:NIOSSLContext)
    {
        self.tls = tls
    }

    @inlinable public static
    var scheme:ServerScheme { .https }
    @inlinable public static
    var domain:String { "127.0.0.1" }
}
