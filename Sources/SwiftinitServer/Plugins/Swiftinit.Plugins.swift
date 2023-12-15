import NIOPosix
import NIOSSL

extension Swiftinit.Plugins
{
    struct List
    {
        let policy:PolicyPlugin?
        let github:GitHubPlugin?

        init(
            policy:PolicyPlugin? = nil,
            github:GitHubPlugin? = nil)
        {
            self.policy = policy
            self.github = github
        }
    }
}
extension Swiftinit
{
    @dynamicMemberLookup
    struct Plugins
    {
        private
        let plugins:List

        let threads:MultiThreadedEventLoopGroup
        let niossl:NIOSSLContext

        init(list plugins:List,
            threads:MultiThreadedEventLoopGroup,
            niossl:NIOSSLContext)
        {
            self.plugins = plugins
            self.threads = threads
            self.niossl = niossl
        }
    }
}
extension Swiftinit.Plugins
{
    subscript<Plugin>(
        dynamicMember keyPath:KeyPath<List, Plugin?>) -> Swiftinit.PluginIntegration<Plugin>?
    {
        self.plugins[keyPath: keyPath].map
        {
            .init(threads: self.threads, niossl: self.niossl, plugin: $0)
        }
    }
}
