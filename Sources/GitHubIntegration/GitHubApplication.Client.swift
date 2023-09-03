import HTTPClient
import JSON
import NIOCore
import NIOHPACK

extension GitHubApplication
{
    @frozen public
    struct Client
    {
        private
        let http2:ClientInterface
        public
        let app:GitHubApplication

        public
        init(http2:ClientInterface, app:GitHubApplication)
        {
            self.http2 = http2
            self.app = app
        }
    }
}
extension GitHubApplication.Client
{
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
                client_id=\(self.app.id)&client_secret=\(self.app.secret)&code=\(code)
                """,

            "accept": "application/vnd.github+json",
        ]

        let response:ClientInterface.Facet
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
