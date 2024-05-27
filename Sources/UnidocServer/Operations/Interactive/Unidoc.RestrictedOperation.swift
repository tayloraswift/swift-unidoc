import GitHubAPI
import HTTP
import MongoDB
import UnidocDB
import UnidocRecords
import UnidocRender

extension Unidoc
{
    /// An endpoint that requires authentication, and possibly authorization.
    public
    protocol RestrictedOperation:InteractiveOperation
    {
        mutating
        func admit(user:Unidoc.UserRights) -> Bool

        /// Obtains the response for this endpoint. The provided session is sequentially
        /// consistent with any authentication that took place before calling this witness.
        consuming
        func load(from server:borrowing Server,
            with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    }
}
extension Unidoc.RestrictedOperation
{
    public consuming
    func load(from server:borrowing Unidoc.Server,
        with state:Unidoc.UserSessionState,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session
        if  server.secure
        {
            let user:Unidoc.UserSession

            switch state.authorization
            {
            case .invalid(let error):
                return .unauthorized("\(error)\n")

            case .web(nil, _):
                guard
                let oauth:GitHub.OAuth = server.github?.oauth
                else
                {
                    return .error("""
                        Server is running in secure mode with no OAuth capability!\n
                        """)
                }

                let login:Unidoc.LoginPage = .init(client: oauth.client,
                    flow: .sso,
                    from: state.request)
                return .ok(login.resource(format: server.format))

            case .web(let session?, _):
                user = .web(session)

            case .api(let session):
                user = .api(session)
            }

            session = try await .init(from: server.db.sessions)

            guard
            let rights:Unidoc.UserRights = try await server.db.users.validate(user: user,
                with: session)
            else
            {
                return .notFound("No such user\n")
            }

            //  We ban this here, so that we can conditionally enforce permissions later by
            //  checking if the user is human.
            if  case .guest = rights.level
            {
                return .unauthorized("""
                    It looks like you are somehow logged in as a non-player entity.\n
                    """)
            }

            guard self.admit(user: rights)
            else
            {
                return .forbidden("Regrettably, you are not a mighty It Girl.\n")
            }
        }
        else
        {
            session = try await .init(from: server.db.sessions)
            //  Yes, we need to call this, even though we ignore the result.
            let _:Bool = self.admit(user: .init(access: [], level: .administratrix))
        }

        return try await self.load(from: server, with: session)
    }
}
