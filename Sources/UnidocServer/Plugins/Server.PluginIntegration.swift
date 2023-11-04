import GitHubAPI
import GitHubClient
import HTTPClient
import NIOPosix
import NIOSSL

extension Server
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

extension Server.PluginIntegration<WhitelistPlugin>
{
    var crawler:WhitelistPlugin.Crawler
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

extension Server.PluginIntegration<GitHubPlugin>
{
    func crawler(db:Server.DB) -> GitHubPlugin.Crawler
    {
        .init(api: self.api, pat: self.plugin.pat, db: db)
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
