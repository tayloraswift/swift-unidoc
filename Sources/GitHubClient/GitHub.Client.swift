import GitHubAPI
import HTTPClient
import JSON
import NIOCore
import NIOHPACK

extension GitHub
{
    @frozen public
    struct Client<Application>
    {
        @usableFromInline internal
        let http2:HTTP2Client
        public
        let app:Application

        public
        init(http2:HTTP2Client, app:Application)
        {
            self.http2 = http2
            self.app = app
        }
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
extension GitHub.Client<GitHub.API>
{
    @available(*, deprecated, message: """
        Create a connection instead, and call the corresponding method on the connection.
        """)
    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String,
        with token:String? = nil) async throws -> Response where Response:JSONDecodable
    {
        try await self.connect { try await $0.get(from: endpoint, with: token) }
    }
}
