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
    var scheme:ServerScheme { .https(port: 8443) }
    @inlinable public static
    var domain:String { "localhost" }
}
