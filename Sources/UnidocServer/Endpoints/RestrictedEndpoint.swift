import MongoDB
import HTTP
import UnidocDB
import UnidocPages
import UnidocRecords

/// Endpoints that require privileged access.
protocol RestrictedEndpoint:InteractiveEndpoint
{
    static
    func admit(user:Unidex.User.ID, level:Unidex.User.Level) -> Bool

    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
}
extension RestrictedEndpoint
{
    static
    func admit(user:Unidex.User.ID, level:Unidex.User.Level) -> Bool
    {
        level == .administratrix
    }

    func load(from server:borrowing Swiftinit.Server,
        with cookies:Swiftinit.Cookies) async throws -> HTTP.ServerResponse?
    {
        if  server.secured
        {
            guard
            let cookie:Unidex.Cookie = cookies.session
            else
            {
                return .redirect(.temporary("\(Site.Login.uri)"))
            }

            let session:Mongo.Session = try await .init(from: server.db.sessions)

            guard
            let (id, level):(Unidex.User.ID, Unidex.User.Level) =
                try await server.db.users.validate(
                    cookie: cookie,
                    with: session),
                Self.admit(user: id, level: level)
            else
            {
                return .forbidden("Regrettably, you are not a mighty It Girl.")
            }
        }

        return try await self.load(from: server)
    }
}
