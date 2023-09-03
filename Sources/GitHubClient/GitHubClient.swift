import GitHubIntegration
import HTTPClient
import JSON
import NIOCore
import NIOHPACK

@frozen public
struct GitHubClient<Application> where Application:GitHubApplication
{
    private
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
extension GitHubClient:Identifiable
{
    @inlinable public
    var id:String { self.app.client }

    @inlinable public
    var secret:String { self.app.secret }
}
extension GitHubClient
{
    public
    func refresh(token:String) async -> Result<GitHubTokens, GitHubAuthenticationError>
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

        return await self.authenticate(sending: request)
    }

    public
    func exchange(code:String) async -> Result<GitHubTokens, GitHubAuthenticationError>
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

        return await self.authenticate(sending: request)
    }

    private
    func authenticate(
        sending request:HPACKHeaders) async -> Result<GitHubTokens, GitHubAuthenticationError>
    {
        let response:HTTP2Client.Facet
        do
        {
            response = try await self.http2.fetch(request)
        }
        catch let error
        {
            return .failure(.fetch(error))
        }

        guard   let headers:HPACKHeaders = response.headers,
                    headers[canonicalForm: ":status"] == ["200"]
        else
        {
            return .failure(.status)
        }

        var json:JSON = .init(utf8: [])
        for buffer:ByteBuffer in response.buffers
        {
            json.utf8 += buffer.readableBytesView
        }

        do
        {
            return .success(try json.decode())
        }
        catch let error
        {
            return .failure(.response(error))
        }
    }
}
