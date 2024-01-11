import GitHubAPI
import HTTPClient
import JSON
import NIOCore
import NIOHPACK
import NIOPosix
import NIOSSL

extension GitHub
{
    @frozen public
    struct Client<Application>
    {
        @usableFromInline internal
        let http2:HTTP2Client
        public
        let app:Application

        private
        init(http2:HTTP2Client, app:Application)
        {
            self.http2 = http2
            self.app = app
        }
    }
}
extension GitHub.Client<GitHub.API<String>>
{
    public static
    func graphql(api:consuming GitHub.API<String>,
        threads:consuming MultiThreadedEventLoopGroup,
        niossl:consuming NIOSSLContext) -> GitHub.Client<GitHub.API<String>>
    {
        .init(http2: .init(
                threads: threads,
                niossl: niossl,
                remote: "api.github.com"),
            app: api)
    }
}
extension GitHub.Client<GitHub.API<Void>>
{
    public static
    func rest(api:consuming GitHub.API<Void>,
        threads:consuming MultiThreadedEventLoopGroup,
        niossl:consuming NIOSSLContext) -> GitHub.Client<GitHub.API<Void>>
    {
        .init(http2: .init(
                threads: threads,
                niossl: niossl,
                remote: "api.github.com"),
            app: api)
    }
}
extension GitHub.Client<GitHub.OAuth>
{
    public static
    func oauth(_ oauth:consuming GitHub.OAuth,
        threads:consuming MultiThreadedEventLoopGroup,
        niossl:consuming NIOSSLContext) -> GitHub.Client<GitHub.OAuth>
    {
        .init(http2: .init(
                threads: threads,
                niossl: niossl,
                remote: "github.com"),
            app: oauth)
    }
}
extension GitHub.Client:Identifiable where Application:GitHubApplication
{
    @inlinable public
    var id:String { self.app.client }

    @inlinable public
    var secret:String { self.app.secret }
}
extension GitHub.Client where Application:GitHubApplication<GitHub.App.Credentials>
{
    public
    func refresh(
        token:String) async throws -> GitHub.App.Credentials
    {
        let request:HPACKHeaders =
        [
            ":method": "POST",
            ":scheme": "https",
            ":authority": "github.com",
            ":path": """
                /login/oauth/access_token?\
                grant_type=refresh_token&\
                client_id=\(self.id)&client_secret=\(self.secret)&refresh_token=\(token)
                """,

            "accept": "application/vnd.github+json",
        ]

        return try await self.authenticate(sending: request)
    }
}
extension GitHub.Client
    where Application:GitHubApplication, Application.Credentials:JSONObjectDecodable
{
    public
    func exchange(
        code:String) async throws -> Application.Credentials
    {
        let request:HPACKHeaders =
        [
            ":method": "POST",
            ":scheme": "https",
            ":authority": "github.com",
            ":path": """
                /login/oauth/access_token?\
                client_id=\(self.id)&client_secret=\(self.secret)&code=\(code)
                """,

            "accept": "application/vnd.github+json",
        ]

        return try await self.authenticate(sending: request)
    }

    private
    func authenticate(sending request:HPACKHeaders)
        async throws -> Application.Credentials
    {
        let response:HTTP2Client.Facet = try await self.http2.fetch(request)

        switch response.status
        {
        case 200?:
            break
        case let status:
            throw AuthenticationError.status(.init(code: status))
        }

        var json:JSON = .init(utf8: [])
        for buffer:ByteBuffer in response.buffers
        {
            json.utf8 += buffer.readableBytesView
        }

        do
        {
            return try json.decode()
        }
        catch let error
        {
            throw AuthenticationError.response(error)
        }
    }
}
extension GitHub.Client
{
    @inlinable public
    func connect<T>(with body:(Connection) async throws -> T) async throws -> T
    {
        try await self.http2.connect
        {
            try await body(Connection.init(http2: $0, app: self.app))
        }
    }
}
