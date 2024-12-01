import NIOSSL

extension HTTP
{
    /// This authority returns detailed error messages to the client, and should not be used
    /// for servers accessible over the public internet.
    @frozen public
    struct IntranetSecure:HTTP.ServerAuthority
    {
        public
        let context:NIOSSLContext
        public
        let binding:Origin

        @inlinable public
        init(context:NIOSSLContext, binding:Origin)
        {
            self.context = context
            self.binding = binding
        }
    }
}
