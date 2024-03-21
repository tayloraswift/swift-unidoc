import HTTP
import MongoDB
import SwiftinitPages
import UnidocDB
import UnidocRecords

/// Endpoints that require privileged access.
protocol RestrictedEndpoint:InteractiveEndpoint
{
    func admit(user:Unidoc.Account, level:Unidoc.User.Level) -> Bool

    consuming
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
}
extension RestrictedEndpoint
{
    func admit(user:Unidoc.Account, level:Unidoc.User.Level) -> Bool
    {
        level == .administratrix
    }

    consuming
    func load(from server:borrowing Swiftinit.Server,
        with cookies:Swiftinit.Cookies,
        as _:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        if  server.secure
        {
            guard
            let user:Unidoc.UserSession = cookies.session
            else
            {
                return .redirect(.temporary("\(Swiftinit.Root.login)"))
            }

            let session:Mongo.Session = try await .init(from: server.db.sessions)

            guard
            let level:Unidoc.User.Level = try await server.db.users.validate(user: user,
                with: session)
            else
            {
                return .notFound("No such user")
            }

            guard self.admit(user: user.account, level: level)
            else
            {
                return .forbidden("Regrettably, you are not a mighty It Girl.")
            }
        }

        return try await self.load(from: server)
    }
}
