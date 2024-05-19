import NIOSSL

extension HTTP
{
    @frozen public
    struct LocalhostSecure:ServerAuthority
    {
        public
        let context:NIOSSLContext

        @inlinable public
        init(context:NIOSSLContext)
        {
            self.context = context
        }

        @inlinable public static
        var scheme:Scheme { .https(port: 8443) }
        @inlinable public static
        var domain:String { "localhost" }
    }
}
