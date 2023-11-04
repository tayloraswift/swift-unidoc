import NIOPosix
import NIOSSL

extension Server
{
    struct Plugins
    {
        let threads:MultiThreadedEventLoopGroup
        let niossl:NIOSSLContext

        let whitelist:WhitelistPlugin?
        let github:GitHubPlugin?

        init(
            threads:MultiThreadedEventLoopGroup,
            niossl:NIOSSLContext,
            whitelist:WhitelistPlugin? = nil,
            github:GitHubPlugin? = nil)
        {
            self.threads = threads
            self.niossl = niossl

            self.whitelist = whitelist
            self.github = github
        }
    }
}
