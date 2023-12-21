import GitHubAPI
import GitHubClient
import HTTPClient
import NIOPosix
import NIOSSL

extension Swiftinit
{
    struct PluginIntegration<Plugin>:Sendable where Plugin:Sendable
    {
        let threads:MultiThreadedEventLoopGroup
        let niossl:NIOSSLContext
        let plugin:Plugin

        init(threads:MultiThreadedEventLoopGroup,
            niossl:NIOSSLContext,
            plugin:Plugin)
        {
            self.threads = threads
            self.niossl = niossl
            self.plugin = plugin
        }
    }
}

extension Swiftinit.PluginIntegration<PolicyPlugin>
{
    var crawler:PolicyPlugin.Crawler
    {
        .init(
            googlebot: .init(
                threads: self.threads,
                niossl: self.niossl,
                remote: "developers.google.com"),
            bingbot: .init(
                threads: self.threads,
                niossl: self.niossl,
                remote: "www.bing.com"))
    }
}

extension Swiftinit.PluginIntegration<GitHubPlugin>
{
    var telescope:GitHubPlugin.RepoTelescope
    {
        .init(api: self.api, pat: self.plugin.pat)
    }
    var monitor:GitHubPlugin.RepoMonitor
    {
        .init(api: self.api, pat: self.plugin.pat)
    }

    var oauth:GitHubClient<GitHubOAuth>
    {
        .init(http2: .init(
                threads: self.threads,
                niossl: self.niossl,
                remote: "github.com"),
            app: self.plugin.oauth)
    }

    var api:GitHubClient<GitHub.API>
    {
        .init(http2: .init(
                threads: self.threads,
                niossl: self.niossl,
                remote: "api.github.com"),
            app: self.plugin.oauth.api)
    }
}
