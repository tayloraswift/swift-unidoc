import Atomics
import GitHubClient
import GitHubAPI
import HTTPClient
import NIOPosix
import NIOSSL

struct GitHubPlugin:Sendable
{
    let niossl:NIOSSLContext
    let count:Counters

    let oauth:GitHubOAuth
    let app:GitHubApp

    init(niossl:NIOSSLContext, oauth:GitHubOAuth, app:GitHubApp)
    {
        self.niossl = niossl
        self.count = .init()

        self.oauth = oauth
        self.app = app
    }
}
extension GitHubPlugin
{
    func partner(on threads:MultiThreadedEventLoopGroup) throws -> Partner
    {
        let root:HTTP2Client = .init(threads: threads,
            niossl: niossl,
            remote: "github.com")
        let api:HTTP2Client = .init(threads: threads,
            niossl: niossl,
            remote: "api.github.com")

        return .init(count: self.count,
            oauth: .init(http2: root, app: self.oauth),
            api: .init(http2: api, app: self.oauth.api))
    }

    func crawl(on threads:MultiThreadedEventLoopGroup, db:Server.DB) async throws
    {
        let api:HTTP2Client = .init(threads: threads,
            niossl: niossl,
            remote: "api.github.com")

        let crawler:Crawler = .init(count: self.count,
            api: .init(http2: api, app: self.oauth.api),
            db: db)

        try await crawler.run()
    }
}
