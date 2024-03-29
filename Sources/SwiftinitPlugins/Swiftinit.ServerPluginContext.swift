import NIOPosix
import NIOSSL

extension Swiftinit
{
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
