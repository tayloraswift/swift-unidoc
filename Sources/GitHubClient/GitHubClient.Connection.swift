import Base64
import GitHubAPI
import HTTPClient
import JSON
import NIOCore
import NIOHPACK
import UnixTime

extension GitHubClient
{
    @frozen public
    struct Connection
    {
        @usableFromInline internal
        let http2:HTTP2Client.Connection
        @usableFromInline internal
        let app:Application

        @inlinable internal
        init(http2:HTTP2Client.Connection, app:Application)
        {
            self.http2 = http2
            self.app = app
        }
    }
}
extension GitHubClient<GitHubOAuth.API>.Connection
{
    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String,
        with token:String? = nil) async throws -> Response where Response:JSONDecodable
    {
        var endpoint:String = endpoint
        var status:UInt? = nil

        following:
        for _:Int in 0 ... 1
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
            else if
                let oauth:GitHubOAuth = self.app.oauth
            {
                let credentials:String = "\(oauth.client):\(oauth.secret)"
                request.add(name: "authorization",
                    value: "Basic \(Base64.encode(credentials.utf8))")
            }

            let response:HTTP2Client.Facet = try await self.http2.fetch(request)

            //  TODO: support If-None-Match
            switch response.status
            {
            case 200?:
                var json:JSON = .init(utf8: [])
                for buffer:ByteBuffer in response.buffers
                {
                    json.utf8 += buffer.readableBytesView
                }

                return try json.decode()

            case 301?:
                if let location:String = response.headers?["location"].first
                {
                    endpoint = String.init(location.trimmingPrefix("https://api.github.com"))
                    continue following
                }

            case 403?:
                if  let second:String = response.headers?["x-ratelimit-reset"].first,
                    let second:Int64 = .init(second)
                {
                    throw GitHubClient<GitHubOAuth.API>.RateLimitError.init(
                        until: .second(second))
                }

            case _:
                break
            }

            status = response.status
            break following
        }

        throw GitHubClient<GitHubOAuth.API>.StatusError.init(code: status)
    }
}
