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

        @inlinable public
        var binding:Origin { .init(scheme: .https, domain: "localhost:8443") }
    }
}
