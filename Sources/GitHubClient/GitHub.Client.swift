import GitHubAPI
import HTTPClient
import JSON
import NIOCore
import NIOHPACK
import NIOPosix
import NIOSSL

extension GitHub {
    @frozen public struct Client<Application> {
        @usableFromInline internal let http2: HTTP.Client2
        public let agent: String
        public let app: Application

        private init(http2: HTTP.Client2, agent: String, app: Application) {
            self.http2 = http2
            self.agent = agent
            self.app = app
        }
    }
}
extension GitHub.Client<Void> {
    public static func graphql(
        niossl: consuming NIOSSLContext,
        on threads: consuming MultiThreadedEventLoopGroup,
        as agent: String
    ) -> GitHub.Client<Void> {
        .init(
            http2: .init(threads: threads, niossl: niossl, remote: "api.github.com"),
            agent: agent,
            app: ()
        )
    }
}
extension GitHub.Client where Application: GitHubApplication {
    public static func rest(
        app: consuming Application,
        niossl: consuming NIOSSLContext,
        on threads: consuming MultiThreadedEventLoopGroup,
        as agent: String
    ) -> GitHub.Client<Application> {
        .init(
            http2: .init(threads: threads, niossl: niossl, remote: "api.github.com"),
            agent: agent,
            app: app
        )
    }

    /// This is almost the same as ``rest(app:niossl:on:as:)``, but it is bound to
    /// the `github.com` apex domain, which is used for initial authentication.
    public static func auth(
        app: consuming Application,
        niossl: consuming NIOSSLContext,
        on threads: consuming MultiThreadedEventLoopGroup,
        as agent: String
    ) -> GitHub.Client<Application> {
        .init(
            http2: .init(threads: threads, niossl: niossl, remote: "github.com"),
            agent: agent,
            app: app
        )
    }
}
extension GitHub.Client: Identifiable where Application: GitHubApplication {
    @inlinable public var id: String { self.app.client }

    @inlinable public var secret: String { self.app.secret }
}
extension GitHub.Client where Application: GitHubApplication<GitHub.App.Credentials> {
    public func refresh(
        token: String
    ) async throws -> GitHub.App.Credentials {
        let request: HPACKHeaders = [
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
    where Application: GitHubApplication, Application.Credentials: JSONObjectDecodable {
    public func exchange(
        code: String
    ) async throws -> Application.Credentials {
        let request: HPACKHeaders = [
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

    private func authenticate(
        sending request: HPACKHeaders
    ) async throws -> Application.Credentials {
        let response: HTTP.Client2.Facet = try await self.http2.fetch(request)

        switch response.status {
        case 200?:
            break
        case let status:
            throw AuthenticationError.status(.init(code: status))
        }

        do {
            let json: JSON = .init(utf8: response.body[...])
            return try json.decode()
        } catch let error {
            throw AuthenticationError.response(error)
        }
    }
}
extension GitHub.Client {
    @inlinable public func connect<T>(
        with body: (Connection) async throws -> T
    ) async throws -> T {
        try await self.http2.connect {
            try await body(Connection.init(http2: $0, agent: self.agent, app: self.app))
        }
    }
}
