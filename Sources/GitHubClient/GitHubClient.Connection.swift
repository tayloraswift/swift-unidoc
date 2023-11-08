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
extension GitHubClient<GitHub.API>.Connection
{
    /// Run a GraphQL API request.
    ///
    /// The request will be charged to the user associated with the given token. It is not
    /// possible to run a GraphQL API request without a token.
    @inlinable public
    func post<Response>(query:String,
        with token:String,
        for _:Response.Type = Response.self) async throws -> Response
        where Response:JSONDecodable
    {
        let request:HTTP2Client.Request = .init(headers:
            [
                ":method": "POST",
                ":scheme": "https",
                ":authority": self.http2.remote,
                ":path": "/graphql",

                "authorization": "Bearer \(token)",

                //  GitHub will reject the API request if the user-agent is not set.
                "user-agent": self.app.agent,
                "accept": "application/vnd.github+json"
            ],
            body: self.http2.buffer(string: query))

        /// GraphQL should never return redirects.
        let response:HTTP2Client.Facet = try await self.http2.fetch(request)

        switch response.status
        {
        case 200?:
            var json:JSON = .init(utf8: [])
            for buffer:ByteBuffer in response.buffers
            {
                json.utf8 += buffer.readableBytesView
            }

            let wrapper:GraphQL.Response<Response> = try json.decode()
            return wrapper.data

        case 403?:
            if  let second:String = response.headers?["x-ratelimit-reset"].first,
                let second:Int64 = .init(second)
            {
                throw GitHubClient<GitHub.API>.RateLimitError.init(
                    until: .second(second))
            }
            else
            {
                fallthrough
            }

        case _:
            throw HTTP.StatusError.init(code: response.status)
        }
    }

    /// Run a REST API request.
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
            let request:HPACKHeaders =
            [
                ":method": "GET",
                ":scheme": "https",
                ":authority": self.http2.remote,
                ":path": endpoint,

                "authorization": token.map { "Bearer \($0)" } ??
                    "Basic \(self.app.oauth.authorization)",

                //  GitHub will reject the API request if the user-agent is not set.
                "user-agent": self.app.agent,
                "accept": "application/vnd.github+json"
            ]

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
                    endpoint = .init(location.trimmingPrefix("https://\(self.http2.remote)"))
                    continue following
                }

            case 403?:
                if  let second:String = response.headers?["x-ratelimit-reset"].first,
                    let second:Int64 = .init(second)
                {
                    throw GitHubClient<GitHub.API>.RateLimitError.init(
                        until: .second(second))
                }

            case _:
                break
            }

            status = response.status
            break following
        }

        throw HTTP.StatusError.init(code: status)
    }
}
