import HTTP
import MongoDB
import SwiftinitPages
import UnidocDB
import UnidocRecords

/// Endpoints that require privileged access.
protocol RestrictedEndpoint:InteractiveEndpoint
{
    static
    func admit(user:Unidoc.User.ID, level:Unidoc.User.Level) -> Bool

    consuming
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
}
extension RestrictedEndpoint
{
    static
    func admit(user:Unidoc.User.ID, level:Unidoc.User.Level) -> Bool
    {
        level == .administratrix
    }

    consuming
    func load(from server:borrowing Swiftinit.Server,
        with cookies:Swiftinit.Cookies) async throws -> HTTP.ServerResponse?
    {
        if  server.secure
        {
            guard
            let cookie:Unidoc.Cookie = cookies.session
            else
            {
                return .redirect(.temporary("\(Swiftinit.Login.uri)"))
            }

            let session:Mongo.Session = try await .init(from: server.db.sessions)

            guard
            let (id, level):(Unidoc.User.ID, Unidoc.User.Level) =
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
