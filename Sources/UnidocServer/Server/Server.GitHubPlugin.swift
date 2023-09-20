import GitHubClient
import GitHubAPI
import HTTPClient
import NIOPosix
import NIOSSL

extension Server
{
    struct GitHubPlugin:Sendable
    {
        let niossl:NIOSSLContext

        let oauth:GitHubOAuth
        let app:GitHubApp

        init(niossl:NIOSSLContext, oauth:GitHubOAuth, app:GitHubApp)
        {
            self.niossl = niossl
            self.oauth = oauth
            self.app = app
        }
    }
}
extension Server.GitHubPlugin
{
    func partner(on threads:MultiThreadedEventLoopGroup) throws -> Server.GitHubPartner
    {
        let root:HTTP2Client = .init(threads: threads,
            niossl: niossl,
            remote: "github.com")
        let api:HTTP2Client = .init(threads: threads,
            niossl: niossl,
            remote: "api.github.com")

        return .init(
            oauth: .init(http2: root, app: self.oauth),
            api: .init(http2: api, app: self.oauth.api))
    }
}
