import NIOSSL

extension HTTP
{
    @frozen public
    enum ServerEncryptionLayer
    {
        /// Encryption happens on this server.
        case local(NIOSSLContext)
        /// Encryption happens on an upstream proxy.
        case proxy
    }
}
