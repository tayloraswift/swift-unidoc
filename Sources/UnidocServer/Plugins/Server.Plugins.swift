import NIOPosix
import NIOSSL

extension Server
{
    struct Plugins
    {
        let threads:MultiThreadedEventLoopGroup
        let niossl:NIOSSLContext

        let policy:PolicyPlugin?
        let github:GitHubPlugin?

        init(
            threads:MultiThreadedEventLoopGroup,
            niossl:NIOSSLContext,
            policy:PolicyPlugin? = nil,
            github:GitHubPlugin? = nil)
        {
            self.threads = threads
            self.niossl = niossl

            self.policy = policy
            self.github = github
        }
    }
}
