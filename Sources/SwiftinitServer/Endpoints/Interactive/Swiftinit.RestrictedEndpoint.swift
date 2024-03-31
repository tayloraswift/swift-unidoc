import GitHubAPI
import HTTP
import MongoDB
import SwiftinitPages
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    /// An endpoint that requires authentication, and possibly authorization.
    protocol RestrictedEndpoint:InteractiveEndpoint
    {
        mutating
        func admit(level:Unidoc.User.Level) -> Bool

        /// Obtains the response for this endpoint. The provided session is sequentially
        /// consistent with any authentication that took place before calling this witness.
        consuming
        func load(from server:borrowing Swiftinit.Server,
            with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    }
}
extension Swiftinit.RestrictedEndpoint
{
    consuming
    func load(from server:borrowing Swiftinit.Server,
        with credentials:Swiftinit.Credentials,
        as _:Swiftinit.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        if  server.secure
        {
            guard
            let user:Unidoc.UserSession = credentials.cookies.session
            else
            {
                if  let oauth:GitHub.OAuth = server.github?.oauth
                {
                    let login:Swiftinit.LoginPage = .init(oauth: oauth,
                        from: credentials.request)
                    return .ok(login.resource(format: server.format))
                }
                else
                {
                    //  Somehow we are running in secure mode without any OAuth capability.
                    return nil
                }
            }

            let session:Mongo.Session = try await .init(from: server.db.sessions)

            guard
            let level:Unidoc.User.Level = try await server.db.users.validate(user: user,
                with: session)
            else
            {
                return .notFound("No such user")
            }

            guard self.admit(level: level)
            else
            {
                return .forbidden("Regrettably, you are not a mighty It Girl.")
            }

            return try await self.load(from: server, with: session)
        }
        else
        {
            let session:Mongo.Session = try await .init(from: server.db.sessions)
            //  Yes, we need to call this, even though we ignore the result.
            let _:Bool = self.admit(level: .administratrix)
            return try await self.load(from: server, with: session)
        }
    }
}
