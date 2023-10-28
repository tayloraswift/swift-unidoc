import NIOPosix
import NIOSSL

extension Server
{
    struct Plugins
    {
        let threads:MultiThreadedEventLoopGroup
        let niossl:NIOSSLContext

        let github:GitHubPlugin?

        init(threads:MultiThreadedEventLoopGroup,
            niossl:NIOSSLContext,
            github:GitHubPlugin? = nil)
        {
            self.threads = threads
            self.niossl = niossl

            self.github = github
        }
    }
}
