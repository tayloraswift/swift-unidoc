import GitHubIntegration
import HTTPClient
import JSON
import NIOCore
import NIOHPACK

@frozen public
struct GitHubClient<Application>
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
extension GitHubClient:Identifiable where Application:GitHubApplication
{
    @inlinable public
    var id:String { self.app.client }

    @inlinable public
    var secret:String { self.app.secret }
}
extension GitHubClient where Application:GitHubApplication<GitHubApp.Credentials>
{
    public
    func refresh(
        token:String) async throws -> GitHubApp.Credentials
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
extension GitHubClient
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
extension GitHubClient<GitHubAPI>
{
    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String,
        with token:String? = nil) async throws -> Response where Response:JSONDecodable
    {
        var request:HPACKHeaders =
        [
            ":method": "GET",
            ":scheme": "https",
            ":authority": "api.github.com",
            ":path": endpoint,

            //  GitHub will reject the API request if the user-agent is not set.
            "user-agent": self.app.agent,
            "accept": "application/vnd.github+json"
        ]
        if  let token:String
        {
            request.add(name: "authorization", value: "Bearer \(token)")
        }

        let response:HTTP2Client.Facet = try await self.http2.fetch(request)

        //  TODO: support If-None-Match
        switch response.status
        {
        case 200?:
            break
        case let status:
            throw StatusError.init(code: status)
        }

        var json:JSON = .init(utf8: [])
        for buffer:ByteBuffer in response.buffers
        {
            json.utf8 += buffer.readableBytesView
        }

        return try json.decode()
    }
}
