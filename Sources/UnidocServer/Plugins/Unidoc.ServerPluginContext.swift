import NIOPosix
import NIOSSL

extension Unidoc
{
    /// A `ServerPluginContext` is an aggregate of a ``MultiThreadedEventLoopGroup`` and
    /// ``NIOSSLContext``. Plugins can use it to create HTTP clients.
    @frozen public
    struct ServerPluginContext:Sendable
    {
        public
        let threads:MultiThreadedEventLoopGroup
        public
        let niossl:NIOSSLContext

        @inlinable public
        init(threads:MultiThreadedEventLoopGroup, niossl:NIOSSLContext)
        {
            self.threads = threads
            self.niossl = niossl
        }
    }
}
